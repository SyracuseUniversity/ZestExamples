# JSON and general objects

Some data isn't as free form as text files but have more complex structure than
arrays of floats (as in [HDF5](hdf5.md)) or even the tables covered in the
[sqlite introduction](sqlite.md).  Such data can often be represented as
[json](https://en.wikipedia.org/wiki/JSON), although other representations are also 
used.

As an example, the history of jobs run on a Slurm cluster can be retrieved
with the `sacct` command which takes an optional `--json` argument which formats the 
results in json.  A greatly stripped-down result might look like this

```json
[
{
  "user": "jdoe",
  "time": {
    "submission": 1771011291,
    "end": 1771426163
  },
  "exit_code": 1,
  "allocated_cpus": [0,1,4,5]
}
,
{
  "user": "jsmith",
  "time": {
    "submission": 1771010021,
    "end": 1771426379
  },
  "exit_code": 0,
  "allocated_cpus": [15,22]
}
]
```


`submission` is the time that the job was submitted, represented as seconds since
January 1, 1970 12:00:00 AM (also called the [epoch
time](https://www.epochconverter.com/)), `end` is the time the job finished in
the same format, and `exit_code` is the status the job exited with, 0 indicating
success.  `allocated_cpus` isn't a real field, but is included here as an example
of array data.


## Working with JSON data in files

The obvious solution is to store one json document per file, and in some cases
that may be the right approach, but it can quickly run into the usual problems
with number of files or size of storage.  This can be alleviated by storing the
json documents within [zip files](zipfiles.md).

The catch here is that working with these files is likely to be slow due to
lack of indices, as discussed in the [sqlite](sqlite.md) page.  For example, to
find all jobs run by jdoe code would need to scan through the zip file, opening
and parsing each json file, to see which ones meet the requirements.  It is
certainly possible for users to create their own indices stored in separate
files, although this is likely to take some effort.  One possibility for this
case is to use [dbm files](https://en.wikipedia.org/wiki/DBM_(computing)), a file
format that efficiently stores key/value pairs, to hold each index.  With this
approach adding a new entry to a json archive would look like:

```python
import json
import dbm
import sys

zipName = sys.argv[1]
newFile = sys.argv[2]

with open(newFile,'r') as json_file:
    json_text = ''.join([line for line in json_file])
    json_data = json.loads(json_text)
    user      = json_data['user']

with ZipFile('all_results.zip','a') as myzip:
    myzip.write(newFile,json_text)
    
    with myzip.open('user_index.dbm','a') as dbmfile:
        if user not in dbmfile:
            dbmfile[user] = ''
        dbmfile[user] = ','.join(dbmfile[user].split(',') + [newFile])
```

## Working with JSON data as sqlite columns

sqlite can store text data of arbitrary length which certainly includes json
formatted text.  However sqlite can go even further, parsing the json data in
select statements.  If a table has been created as

```sql
CREATE TABLE json_data(contents TEXT);
```

and the above data has been loaded into this table then data can be
selected with expressions like

```sql
SELECT json_extract(contents, '$.user') FROM json_data;

SELECT json_extract(contents, '$.time.end') FROM json_data;

SELECT json_extract(contents, '$.allocated_cpus[2]') FROM json_data;

SELECT json_extract(contents, '$.user') FROM json_data
  WHERE json_extract(contents, '$.time.submission') > 1771011000;
```


## Working with JSON data as sqlite tables

Finally, the most efficient way of using json data is to map the structure of the
documents to sqlite tables.  For the current examples these tables would look like

```sql
CREATE TABLE job (
  jobId           INTEGER,
  user            VARCHAR(100),
  timeId          INTEGER,
  exit_code       INTEGER,
  allocatedCpusId INTEGER
)

CREATE TABLE time (
  timeId     INTEGER,
  submission INTEGER,
  end_time   INTEGER
)

CREATE TABLE allocated_cpus (
  allocatedCpusId INTEGER,
  arrayIndex      INTEGER,
  value           INTEGER
)
```

The job table would contain

```
1,"jdoe",1,1,1
2,"jsmith",2,0,2
```

the time table
```
1,1771011291,1771426163
2,1771010021,1771426379
```
the allocated_cpus table

```
1,1,0
1,2,1
1,3,4
1,4,5
2,1,15
2,2,22
```

This allows for efficient searching, especially if indices are used, but at the cost 
of needing potentially complex queries and the need to write code that converts between
the json and table representations.

---

Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
