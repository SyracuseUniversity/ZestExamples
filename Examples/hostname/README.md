# Hostname

This is a very simple Slurm example that simply runs a command somewhere
in the pool of resources.  The command is `hostname` which, as the name implies,
returns the name of the computer.  You can try it manually from the command line

```bash
hostname
```

which will print something like

```
its-zest-login2.ad.syr.edu
```

although the name may be different.

Next, to run the command through Slurm

```bash
sbatch hostname.sh
```

Slurm will respond with `Submitted batch job` and a job number.  You can then
check the status of your job with

```bash
squeue --me
```

The job should move from the PD (pending) state to the R (running) state and
then complete, although this may happen too fast to notice.  If `squeue`
reports no jobs then it has completed.  Check the output with

```bash
cat output/hostname.out
```

It will contain the name of the node where Slurm placed the job, for example
`node1142`.

## The batch script

Open `hostname.sh` to see how the job was described.  A Slurm batch script is
just a shell script, the lines beginning with `#SBATCH` are read by Slurm when
the job is submitted and are ignored by the shell.

```bash
#SBATCH --job-name=hostname
#SBATCH --output=output/hostname.out
#SBATCH --error=output/hostname.err
#SBATCH --partition=compute_zone2,normal
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00
```

A few things worth knowing:

  * The job runs in the directory you submitted it from, so relative paths
    such as `output/hostname.out` work.  The `output` directory must already
    exist, Slurm will not create it and the job will fail if it can't write
    its output file.
  * `--partition` lists the groups of nodes the job may run on.  Zest's
    partitions are `normal`, `longjobs`, `compute_zone2`, `gpu` and `gpu_zone2`.
    Giving a comma separated list lets Slurm start the job in whichever
    partition has room first.  Run `sinfo` to see them all.
  * `--time` is the maximum time the job is allowed to run.  Shorter limits
    make it easier for Slurm to find a slot for your job, and jobs are killed
    when the limit is reached, so make it generous but realistic.
  * If you don't ask for memory Slurm gives you 2 GB per CPU.  Use `--mem=8G`
    (per node) or `--mem-per-cpu=4G` to request more.

All of these can also be given on the command line, for example
`sbatch --time=01:00:00 hostname.sh`, which overrides the value in the file.

## Checking on a finished job

Once a job is gone from `squeue` its record is kept by the accounting system.
The `sacct` command shows it, with `-j` taking the job number that `sbatch`
printed

```bash
sacct -j 3127657 --format=jobid,jobname,partition,state,exitcode,elapsed,nodelist
```

and `seff` summarizes how much of the requested CPU and memory a job actually
used, which is useful for tuning future requests

```bash
seff 3127657
```

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
