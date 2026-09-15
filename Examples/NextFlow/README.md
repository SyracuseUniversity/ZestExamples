# NextFlow

[NextFlow](https://www.nextflow.io/) is a framework for creating scientific
workflows with an emphasis on how data moves between various stages of
processing.  It is inspired in part by the [Unix
Philosophy](https://en.wikipedia.org/wiki/Unix_philosophy), encapsulated in the
way data flows between processes connected by pipes, for example to sum the
cumulative number of lines in all text files within a directory and its
subdirectories.

```bash
find . | grep txt | xargs cat | wc -l
```

NextFlow is also based on the idea of [dataflow
programming](https://en.wikipedia.org/wiki/Dataflow_programming), a model with
some similarities to functional programming as discussed in the documentation on
[parallel programming](../Parallelism).  There is also a paper on [Programming
Languages for Distributed Computing
Systems](https://ranger.uta.edu/~weems/NOTES6350/p261-bal.pdf) that is cited in
the NextFlow documentation that may be helpful in understanding its underlying
model.


## Installation

NextFlow itself is written in Java, although it can run workflows in any
language.  Zest's system Java is too old (version 8, NextFlow needs 17 or
later) so the first step in installation is to install Java, which can most
easily be done through Conda.  First, set up a Conda installation according
to the instructions in the [python](../python) documentation, then create an
environment and install Java


```bash
eval "$(${HOME}/miniconda3/bin/conda shell.bash hook)"
conda create -y -n nextflow conda-forge::openjdk=17
conda activate nextflow
```

Once that's done, install NextFlow from the installer on the site

```bash
curl -s https://get.nextflow.io | bash
```

This will place the `nextflow` executable in the current directory, move it
somewhere on your `$PATH` such as `~/bin` (the batch script below assumes
`~/bin/nextflow`).  Java must be available whenever NextFlow runs, so activate
the `nextflow` environment first.


## Defining a workflow

In the simplest use NextFlow resembles many other programming languages,
processes are defined like functions, and then called by the workflow.


```
process sayHello {
    script:
    """
    echo 'Hello'
    """
}

workflow {
    sayHello()
}
```

If this code is placed in a file called `workflow.nf` then it can be run with
the command

```bash
nextflow run workflow.nf
```

Various diagnostic information will be printed, but the message itself won't be.
In order to capture the output it must be sent to a file, and the file should be
listed as an output of the process:


```
process sayHello {
    output:
        path "hello.txt"

    script:
    """
    echo 'Hello' > hello.txt
    """
}

workflow {
    sayHello()
}
```

If a full path is not specified then the file will end up somewhere under the
`work` directory that NextFlow creates to manage data.  For example in one test
run the file ended up as `work/b3/87ec8808079e803aed52bd77d2b229/hello.txt`.


## Chaining processes

Of course workflows are not restricted to a single process.  Multiple processes
can be defined and the workflow can wire them together, this wiring occurs
through a
[channel](https://training.nextflow.io/latest/hello_nextflow/02_hello_channels/).
Channels are in many ways the core of NextFlow, as the documentation states they
are

> queues designed to handle inputs efficiently and shuttle them from one step to
> another in multi-step workflows, while providing built-in parallelism and many
> additional benefits.

The file `hello.nf` in this directory is an example that creates a file
containing "hello" and then a second file that appends "world":

```
process sayHello {
    input:
    val greeter

    output:
    path 'hello.txt'

    script:
    """
    echo -n '${greeter} says: hello' > hello.txt
    """
}

process addWorld {
    input:
    path input_file

    output:
    path 'helloworld.txt'

    script:
    """
    cat ${input_file} > helloworld.txt
    echo ' world' >> helloworld.txt
    """
}


workflow {
  def query_ch = channel.of('nextflow', 'Zest')
  sayHello(query_ch)
  addWorld(sayHello.out).view()
}
```

This reports the locations of two files, one containing "nextflow says: hello
world" and the other "Zest says: hello world", because the channel was given
two values and NextFlow ran the pair of processes once for each.  Adding more
values to the channel is all it takes to parallelize the workflow further.


## Channels are more than pipes

Channels support an entire programming language.  In addition to the official
NextFlow documentation there is a nice presentation on this
[here](https://icbi-lab.github.io/current-topics-bioinformatics-lecture/07_nextflow_dsl2.html).
As an example, this workflow sums the squares of the integers from 1 to 5.

```
workflow {
    Channel
        .of(1..5)
        .map { it * it }
        .sum()
        .view { result -> "sum of squares = $result" }
}
```

This is conceptually very similar to the Python code

```python
sum(map(lambda it: it*it, range(1,6)))
```


## Running on Zest

NextFlow processes are run by an
[executor](https://www.nextflow.io/docs/latest/executor.html), which so far has
been hidden but which can be configured to run on a wide variety of systems.
The good news is that NextFlow supports Slurm natively, it is just necessary
to say so in a configuration file.  The `nextflow.config` in this directory
does that, along with the resources each job should ask for:

```
process {
    executor = 'slurm'
    queue    = 'compute_zone2,normal'   // Slurm partition(s)
    cpus     = 1
    memory   = '1 GB'
    time     = '10m'
}

executor {
    queueSize       = 20     // at most this many jobs in the queue at once
    pollInterval    = '15 sec'
    submitRateLimit = '10/1min'
}
```

NextFlow reads `nextflow.config` from the current directory, so with this in
place running the "hello world" workflow will run the "nextflow" and "Zest"
processes as Slurm jobs, in parallel.  Copy the file to `~/.nextflow/config`
to make it the default for all workflows.

Alternately, if only some processes should be handed over to Slurm, the
executor can be specified for each process

```
process run_on_slurm {
    executor = 'slurm'
    ...
```

If any additional `#SBATCH` options are needed by a process they can be
specified as `clusterOptions`. For example if a process needs to run on a GPU:

```
process run_on_gpu {
    queue = 'gpu_zone2,gpu'
    clusterOptions = '--gres=gpu:1'
    ...
```

As with Snakemake, the `nextflow` command keeps running until the whole
workflow has finished, which for a long workflow means it should itself be
run as a small Slurm job rather than on the login node.  The batch script
`run_nextflow.sh` in this directory does this for `hello.nf`:

```bash
sbatch run_nextflow.sh
```

Its output, in `output/nextflow.out`, shows the two `sayHello` and two
`addWorld` processes being submitted, and `squeue --me` shows them as jobs
named `nf-sayHello_(1)` and so on while they run.  NextFlow keeps its own
detailed log in `.nextflow.log` and every job's script and output under
`work/`.

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
