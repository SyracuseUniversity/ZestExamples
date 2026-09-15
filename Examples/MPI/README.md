# A simple MPI example

This is an example written in C, taken from
[the official OpenMPI repository](https://github.com/open-mpi/ompi/blob/main/examples/ring_c.c).
This example creates a number of processes that communicate over MPI and pass a
simple message around the processes in a ring.  See the comments in the C file
for more details.

## MPI on Zest

Zest provides OpenMPI 4.1.6 (built with the GNU 12 compilers) through the
OpenHPC module system.  The `gnu12` and `openmpi4` modules are loaded
automatically when you log in, so `mpicc` and friends are already on your
path

```bash
$ module list
Currently Loaded Modules:
  1) autotools   3) gnu12   5) hwloc   7) libfabric   9) pmix
  2) prun        4) ohpc    6) ucx     8) openmpi4   10) singularity

$ which mpicc
/opt/ohpc/pub/mpi/openmpi4-gnu12/4.1.6/bin/mpicc
```

(the real output also shows version numbers, which are omitted here because
they change when the cluster is updated.)

MPICH (`mpich/3.4.3-ofi`) and MVAPICH2 are also available as modules for
codes that require them, use `module swap openmpi4 mpich` to switch.

## Running the example

First compile the code with:

```bash
mpicc ring_c.c -o ring
```

then submit it to the cluster with

```bash
sbatch ring.sh
```

You can then check the status of your job with

```bash
squeue --me
```

The job should move from the PD (pending) state to the R (running) state and
then complete, although this may happen too fast to notice.  If `squeue`
reports no jobs then it has completed.  Check the output with

```bash
cat output/ring-*.out
```

It will show process 0 sending a message around the ring of four processes ten
times, followed by each process exiting.

## The batch script

The interesting lines in `ring.sh` are

```bash
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=1

module purge
module load gnu12 openmpi4

mpirun ./ring
```

Slurm allocates two nodes and reserves room for two *tasks* (MPI processes)
on each, four in total.  `mpirun` then starts one copy of `./ring` per task,
spread across the nodes, and connects them together.  There is no need to
give `-np` or a host list, OpenMPI's `mpirun` reads them from the job's
allocation.

A few things to note:

  * Use `mpirun`, not `srun`, to start MPI programs on Zest.  If you have
    followed a tutorial written for another cluster and see an error
    beginning "The application appears to have been direct launched using
    srun", replace `srun` with `mpirun`.
  * Always load modules inside the batch script, starting with `module purge`
    and using module names without version numbers (`gnu12 openmpi4` rather
    than `gnu12/12.3.0 openmpi4/4.1.6`).  A batch job otherwise inherits
    whatever environment the login shell had, and the job then uses the
    compiler and MPI libraries that are installed on the node it is
    actually running on.  Starting every batch script this way is a good
    habit and avoids a class of hard-to-diagnose library errors.
  * If you have Conda installed there is a good chance it has put a different
    `mpirun` on your path (Conda packages often bring their own MPI), which
    will fail in confusing ways.  `which mpirun` should print a path under
    `/opt/ohpc`, if it does not either `conda deactivate` before submitting or
    use the full path, `$MPI_DIR/bin/mpirun`, in the script.
  * Always use `./ring`, not `ring`.  The current directory is not on the
    search path, so `ring` on its own gives "No such file or directory".
  * To run more processes just change `--nodes` and `--ntasks-per-node`.  The
    nodes in `compute_zone2` have 336 cores and those in `normal` 112 to 192,
    so many MPI jobs can fit on a single node, which is more efficient than
    spreading across several.
  * For programs that combine MPI with OpenMP threads, raise `--cpus-per-task`
    and set `OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK` in the script.

## What to read next

The [mpi4py](../mpi4py) example runs the same ring in Python, and
[Parallelism](../Parallelism) discusses when MPI is the right tool compared to
job arrays.

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
