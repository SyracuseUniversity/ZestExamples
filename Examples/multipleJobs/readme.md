# Multiple Jobs

Very often the same program needs to be run many times with different
arguments, for example once for each of a hundred input files or parameter
settings.  Slurm's mechanism for this is the *job array*.  The full
documentation is [here](https://slurm.schedmd.com/job_array.html) but this
example illustrates one powerful technique, reading a set of arguments from a
file.

## Running the sample program

This directory contains a sample program `demo.sh` which simply echos the first
two arguments passed to it.  The batch script, `demo_array.sh` runs it five
times with arguments taken from `demo.dat`.  The key line is

```bash
#SBATCH --array=1-5
```

which tells Slurm to create five copies of the job.  Each copy has the
environment variable `SLURM_ARRAY_TASK_ID` set to a different number from 1 to
5, and the script uses that number to pick a line out of `demo.dat`

```bash
line=$(sed -n "${SLURM_ARRAY_TASK_ID}p" demo.dat)
read -r arg1 arg2 <<< "$line"

./demo.sh "$arg1" "$arg2"
```

The output files are numbered in the same way, `%a` in an `#SBATCH --output`
line is replaced by the task ID.  One key point to note is that all five copies
are run simultaneously if there is room on the cluster, each as a separate job.

To submit this to the cluster the command is

```bash
sbatch demo_array.sh
```

After submitting you can check on the progress with

```bash
squeue --me
```

or monitor it with

```bash
watch -n 5 squeue --me
```

While the array is pending `squeue` shows it as a single line, for example
`3127700_[1-5]`, as the tasks start they appear as separate lines
`3127700_1`, `3127700_2` and so on.

When it completes you can check the outputs with

```bash
cat output/demo_*.out
```

## Variations

The array specification is flexible.  A few useful forms are

  * `--array=0-99` runs 100 tasks numbered from zero.
  * `--array=1,5,9` runs just those three tasks, handy for rerunning failures.
  * `--array=1-1000%20` runs 1000 tasks but only 20 at a time, which is polite
    when each task is short and the cluster is busy.

The number of lines in a data file can be used to size the array
automatically at submit time

```bash
sbatch --array=1-$(wc -l < demo.dat) demo_array.sh
```

Each task in an array is a full job with its own CPU, memory and time
request, taken from the `#SBATCH` lines, so an array is the right tool
whenever the tasks are independent of each other.  The largest array Zest
allows is 1000 tasks, for more than that either submit several arrays or
have each task handle several lines of the data file.

## What to read next

The [Parallelism](../Parallelism) document discusses how to break a problem
into independent pieces that fit this pattern and how to combine the results
afterwards using job dependencies.

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
