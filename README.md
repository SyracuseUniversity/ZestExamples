# ZestExamples
![Zest logo image](https://researchcomputing.syr.edu/wp-content/uploads/mathew-schwartz-P-WWHRF7qe0-unsplash-620x413-1-1.jpg)

This repository provides code examples for regularly used applications within the Zest cluster.
In addition to exploring these examples on the web you can use [git](https://www.w3schools.com/git/git_intro.asp?remote=github)
to download them into your home directory on the cluster which will allow you to run them directly.  The command is

```
git clone http://github.com/SyracuseUniversity/ZestExamples
```

## Start here

* [hostname](hostname): A simple example of submitting a job to the cluster, monitoring it, and checking its output.

## Getting the most out of Zest

* [Checkpointing](Checkpointing): Learn how to save the state of long-running jobs so Slurm (or your application) can resume them where they left off if a node goes down, with worked examples for GROMACS and LAMMPS.

## Using particular languages and libraries

* [Python](Python): Use Python and the mpi4py library to communicate between processes with MPI.
* [MPI](MPI): Run a simple C-based MPI example that passes messages between processes in a ring.

## GPU and specialized applications

* [GPU](GPU): Submit a job to Zest's GPU partitions and confirm the GPU is visible to your job with nvidia-smi.
* [GROMACS](GROMACS): Run a small GROMACS molecular dynamics job on Zest's GPU partitions.

## Need Help?

Additional how-to documentation, such as connecting to the cluster and running jobs, is [available at docs.syr.edu](https://docs.syr.edu/ResearchComputing/). If you would like to contact us directly for assistance or requesting access, email [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
