# A simple MPI example

This is an example written in C, taken from 
[the offical OpenMPI respository](https://github.com/open-mpi/ompi).
This example creates a number of processes that communicate over MPI and pass a
simple message around the processes in a ring.  See the comments in the c file
for more details.

To run it, first download the code:

```bash
wget https://raw.githubusercontent.com/open-mpi/ompi/main/examples/ring_c.c
```

then compile it with:

```bash
mpicc ring_c.c -o ring
```

and finally submit it to the cluster with 

```bash
sbatch ring.sh
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
cat output/ring.out
```

It will contain the name of the node where Slurm placed the job.

