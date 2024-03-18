# Hostname

This is a very simple Slurm example that simply runs a command somewhere
in the pool of resources.  The command is `hostname` which, as the name implies,
returns the name of the computer.  You can try it manually from the command line

```bash
hostname
```

which will print something like

```
its-zest-login3.ad.syr.edu
```

although the name may be different.

Next, to run the command though HTCondor

```bash
sbatch hostname.sh
```

You can then check the status of your job with

```bash
squeue -u netid
```

(replace "netid" with your SU netID).  The job should move from the PD
(pending) state to the R (run) state and then complete, although this may
happen too fast to notice.  If `squeue` reports that you have no jobs then it
has completed.  Check the output with

```bash
cat output/hostname.out
```

It will contain the name of the node where Slurm placed the job.

