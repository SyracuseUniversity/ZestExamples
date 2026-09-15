# Zest Examples
<img width="100" height="100" src="https://researchcomputing.syr.edu/wp-content/uploads/mathew-schwartz-P-WWHRF7qe0-unsplash-620x413-1-1.jpg"/>

This repository provides code examples for commonly used applications within the Zest cluster.
In addition to exploring these examples on the web you can use [git](https://www.w3schools.com/git/git_intro.asp?remote=github)
to download them into your home directory on the cluster which will allow you to run them directly.  The command is

```
git clone https://github.com/SyracuseUniversity/ZestExamples
```

Zest is a [Slurm](https://slurm.schedmd.com/) cluster.  Users coming from
OrangeGrid will find the same set of examples in the
[OrangeGridExamples](https://github.com/SyracuseUniversity/OrangeGridExamples)
repository written for HTCondor, the two are kept in step so that the same
program can be moved between clusters by swapping the submit file.

## Start here

* [hostname](Examples/hostname): A simple example of submitting a job to the cluster, monitoring it, and checking its output, with an introduction to batch scripts and the options every job should set.

## Getting the most out of Zest

These examples discuss general techniques for optimizing performance and throughput

  * [Checkpointing](Examples/Checkpointing): Learn how to save work that your jobs are doing, so if they are interrupted or hit their time limit they can be requeued and restart where they left off.  Includes worked examples for GROMACS and LAMMPS.
  * [Parallelism](Examples/Parallelism): Learn how to divide a task into lots of smaller tasks that can run independently so they can spread out over the cluster, using job arrays and job dependencies.
  * [File management](Examples/FileManagement): Learn how to arrange your data into chunks that are both more efficient for later analyses and perform better on the cluster.
  * [multipleJobs](Examples/multipleJobs): Learn how to run multiple jobs from one batch script with a job array.
  * [SlurmDiagnostics](Examples/SlurmDiagnostics): Check the status of the cluster and of your own jobs.


## Using particular languages and libraries

  * [python](Examples/python): Use Python and Python packages with the Conda package manager.
  * [uv](Examples/uv): Use Python and Python packages with the uv package manager.
  * [MPI](Examples/MPI): Run a C program across several nodes with OpenMPI.
  * [mpi4py](Examples/mpi4py): Do the same from Python with the mpi4py library.
  * [tensorflow](Examples/tensorflow): Use the Tensorflow package on a GPU.
  * [PyTorch](Examples/PyTorch): Use the PyTorch package on a GPU (note, the [uv](Examples/uv) example also covers this in a way that may be easier to use).
  * [JAX](Examples/JAX): Optimize certain mathematical operations on GPUs.
  * [Ollama](Examples/Ollama): Run an LLM non-interactively, choosing from among numerous models.
  * [julia](Examples/julia): Use the Julia language and its libraries.
  * [octave](Examples/octave): Use Octave, a free and open source math-oriented language that is largely compatible with Matlab.
  * [R](Examples/R): Use the R language and its libraries.
  * [Singularity](Examples/Singularity): Simplify the installation of complex packages by pulling containers from Dockerhub.
  * [GPU](Examples/GPU): Request a GPU and confirm that your job can see it.
  * [GROMACS](Examples/GROMACS): Run a small GROMACS molecular dynamics job on a GPU using the centrally installed module.
  * [CUDA 13](Examples/CUDA13): Use GPUs with code requiring the latest versions of the CUDA library.

## Workflow managers

Single batch scripts are great for anything from a single job to thousands of
jobs where the same command is run on numerous arguments.  However research
often entails more complex arrangements of jobs, where an initial stage will
create files which are needed by a later stage or post processing can only be run
once a set of analyses have completed.  In general there may be arbitrary
*dependencies* between jobs.  While it is always possible to manage these
manually, waiting for one set of jobs to complete before running the next, it is
much more convenient to have a workflow manager handle the dependencies.  There
are many such systems, suitable for different situations.

  * [Job dependencies](Examples/Parallelism#structuring-slurm-jobs-with-dependencies)
    are Slurm's native mechanism.  A job can be told to wait for other jobs
    to finish (successfully or otherwise) before it starts, and a short
    script can wire up a whole workflow this way.  We discuss this in the
    section on [Parallelism](Examples/Parallelism).

  * [Snakemake](Examples/Snakemake) is a tool for running workflows specified by
    the relationships between input and output files of individual processes.
    It can submit each step as a Slurm job.

  * [NextFlow](Examples/NextFlow) is a framework for creating scientific workflows with an emphasis on how data moves between various stages of processing. It is
    inspired in part by the [Unix Philosophy](https://en.wikipedia.org/wiki/Unix_philosophy) encapsulated in the way data flows between processes connected by pipes.
    It has built-in support for Slurm.

## Need Help?

Additional how-to documentation, such as connecting to the cluster and running jobs, is [available at docs.syr.edu](https://docs.syr.edu/ResearchComputing/).

If you would like to contact us directly for assistance or requesting access, email [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
