# Snakemake

[Snakemake](https://snakemake.readthedocs.io/en/stable/) specifies the
dependency relationships between files, and by implication the processes that
produce them, in a manner very similar to the way the Unix utility
[make](https://en.wikipedia.org/wiki/Make_(software)) works.  Snakemake
configuration files consist of a set of rules for how to produce files, when a
user asks Snakemake to generate a file it first checks to see if that file
already exists, if not it consults its rules for how to make it.  The process of
making the file will typically depend on the existence of other files, it sees
if those exist and if not looks for rules to make them, and so on recursively.
This may be a shift in mindset to how workflows are usually envisioned, as a
sequence of processes to run, but it can be a powerful model.

## Installing Snakemake

Snakemake is easiest to install through Conda.  If you don't already have a
Conda installation the steps are

```bash
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"

bash Miniforge3-$(uname)-$(uname -m).sh -b -p $HOME/miniconda3
```

Then to install Snakemake, along with the plugin that lets it submit Slurm
jobs, into a fresh environment

```bash
eval "$(${HOME}/miniconda3/bin/conda shell.bash hook)"
conda create -c conda-forge -c bioconda -n snakemake snakemake snakemake-executor-plugin-slurm
conda activate snakemake
```

## Using Snakemake

The rules to construct files are specified in a `Snakefile`.  The simplest
example produces one file and doesn't require any inputs:

```python
rule hello:
    output:
        "hello.txt"
    shell:
        "echo -n 'Hello ' > {output}"
```

The command to run this is

```bash
snakemake --cores 1 hello.txt
```

The `cores` parameter tells Snakemake how many CPUs to run on, this is useful
for parallelizing workflows.  At the moment though there's just one task, so
nothing to parallelize.  When run, Snakemake will display a lot of information
about how it is resolving the dependencies, and after it completes the file
`hello.txt` will be available.

Attempting to run a second time will report

```
Nothing to be done (all requested files are present and up to date).
```

In practice Snakefiles will specify multiple dependent rules.  The mechanism to
indicate that one rule relies on another one is the `input` tag.

```python
rule hello:
    output:
        "hello.txt"
    shell:
        "echo -n 'Hello ' > {output}"

rule world:
    output:
        "world.txt"
    shell:
        "echo 'world!' > {output}"

rule hello_world:
    input:
        "hello.txt",
        "world.txt"
    output:
        "hello_world.txt"
    shell:
        "cat hello.txt world.txt > {output}"
```

Here when Snakemake is asked for `hello_world.txt` it determines that it first
needs to generate `hello.txt` and `world.txt` (although if `hello.txt` is still
present from the previous run it will not be regenerated).

Next, note that `hello.txt` and `world.txt` do not depend on each other, so they
could be built simultaneously.  To see this in action, first add a delay to the
rules:

```python
rule hello:
    output:
        "hello.txt"
    shell:
        "sleep 30 && echo -n 'Hello ' > {output}"

rule world:
    output:
        "world.txt"
    shell:
        "sleep 30 && echo 'world!' > {output}"
```

Then in a second window run

```bash
top -u $(whoami)
```

Then in the first window remove the previously generated files and rerun with
two cores

```bash
rm hello.txt world.txt hello_world.txt
snakemake --cores 2 hello_world.txt
```

and watch the second window.  Two `sleep` jobs will be visible, indicating that
the first two rules are running simultaneously.

Note that this runs the work on the login node, which is fine for a quick
test like this but not for real computation.


## Using Snakemake with Slurm

Snakemake has an executor plugin for Slurm, installed above, which submits
each rule as a separate Slurm job.  To use it add `--executor slurm` and say
how many jobs may be in the queue at once with `--jobs`:

```bash
rm hello.txt world.txt hello_world.txt
snakemake --executor slurm --jobs 2 --latency-wait 60 hello_world.txt
```

In another window run

```
watch squeue --me
```

and you should see two jobs start up, one for each of the parallelizable files,
followed by a third for `hello_world.txt`.

The `--latency-wait 60` option is important on Zest, as on any cluster with
network home directories.  A file written by a job on one node can take
several seconds to become visible on the node where Snakemake is running,
because NFS clients cache directory listings for a while.  Snakemake's
default is to wait only 5 seconds before declaring that a job "completed
successfully, but some output files are missing", which makes workflows fail
at random.  Sixty seconds is the value the Snakemake documentation suggests
for network filesystems and worked reliably in our tests.

Each rule needs to tell Slurm what resources it needs, in the same way that a
batch script has `#SBATCH` lines.  This is done with a `resources` section in
the rule, for example

```python
rule hello:
    output:
        "hello.txt"
    resources:
        slurm_partition="compute_zone2,normal",
        runtime=5,          # minutes
        mem_mb=1000,
        cpus_per_task=1,
    shell:
        "echo -n 'Hello ' > {output}"
```

A GPU rule would add `slurm_extra="--gres=gpu:1"` and use the `gpu_zone2,gpu`
partitions.  Rather than repeating these in every rule they can be given on
the command line as defaults

```bash
snakemake --executor slurm --jobs 10 --latency-wait 60 \
    --default-resources slurm_partition=compute_zone2,normal runtime=10 mem_mb=1000 \
    hello_world.txt
```

or, better, put in a *profile* so that they don't have to be typed each time.
Create `~/.config/snakemake/zest/config.yaml` containing

```yaml
executor: slurm
jobs: 10
latency-wait: 60
default-resources:
  slurm_partition: "compute_zone2,normal"
  runtime: 10
  mem_mb: 1000
```

after which `snakemake --profile zest hello_world.txt` does the same thing.
The full list of resource names is in the [plugin
documentation](https://snakemake.github.io/snakemake-plugin-catalog/plugins/executor/slurm.html).

However, even as the Slurm jobs are running the Snakemake command will still
be active.  Since Snakemake is not inherently designed as a distributed system
it runs cluster jobs the same way it runs local processes, it starts a command
and waits for it to finish.  This is OK for short workflows, but is a problem
for longer ones that may run several days, since it means staying logged in.

The solution is to run the Snakemake process itself as a Slurm job.  Unlike
some clusters, Zest allows jobs to be submitted from the compute nodes, so
this just works.  The batch script `run_snakemake.sh` in this directory does
it for the sum of squares example below, it asks for a single CPU and a
generous time limit, activates the Conda environment and runs

```bash
snakemake --executor slurm --jobs 5 --latency-wait 60 sum_of_squares.txt
```

Submit it with `sbatch run_snakemake.sh` and the whole workflow proceeds
without further attention.  The controlling job's own output is in
`output/snakemake.out`, the individual rule jobs write their logs under
`.snakemake/slurm_logs/`.


## A more complex example

The `Snakefile` in this directory is a somewhat more elaborate example that
utilizes some additional features to compute the squares of the first five
positive integers, then adds them together.


```python
rule square:
    output:
        "squares/square_{i}.txt"
    resources:
        slurm_partition="compute_zone2,normal",
        runtime=5,
        mem_mb=1000,
    run:
        i = int(wildcards.i)

        result = i ** 2

        with open(output[0], "w") as f:
            f.write(str(result))

rule sum:
    input:
        expand("squares/square_{i}.txt", i=range(1, 6))
    output:
        "sum_of_squares.txt"
    resources:
        slurm_partition="compute_zone2,normal",
        runtime=5,
        mem_mb=1000,
    run:
        total = 0

        for file in input:
            with open(file, "r") as f:
                total += int(f.read().strip())

        with open(output[0], "w") as f:
            f.write(f"{total}\n")
```

The most immediate thing to notice is that the rules have `run:` sections rather
than `shell:`.  This demonstrates one of the key features of Snakemake, the
ability to embed Python code directly.  In fact Snakemake describes Snakefiles
as a Python-based language.

Next, notice the use of the `expand` function.  As might be expected, this is a
compact way of specifying that the input files are `square_1.txt` through
`square_5.txt`.

Finally, `wildcards` is a special *namespace*, within this namespace `i` is
bound by matching the pattern of the output file with the name requested by the
input file of the `sum` rule.  For more on wildcards, see [this book
draft](https://farm.cse.ucdavis.edu/~ctbrown/2023-snakemake-book-draft/beginner+/wildcards.html#the-wildcard-namespace-is-implicitly-available-in-input-and-output-blocks-but-not-in-other-blocks).

Just as with the previous example, this can run directly with

```bash
snakemake --cores 5 sum_of_squares.txt
```

Or it can be distributed to the cluster with

```bash
snakemake --executor slurm --jobs 5 --latency-wait 60 sum_of_squares.txt
```

or by submitting `run_snakemake.sh`.  Either way the answer, 55, ends up in
`sum_of_squares.txt`.


## Where Snakemake fits

Compared with the hand-rolled dependency chains in the
[Parallelism](../Parallelism) example, Snakemake keeps track of what has
already been produced, so a workflow that failed half way through can simply
be rerun and picks up where it left off, and it handles the bookkeeping of
hundreds of intermediate files.  The cost is one more tool to learn and an
extra long-running controller job.  For workflows of a handful of steps
plain `sbatch --dependency` is often enough, for anything larger Snakemake or
[NextFlow](../NextFlow) will pay for itself quickly.

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
