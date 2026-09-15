#!/bin/bash

#SBATCH --job-name=ring                  ## Name of job
#SBATCH --output=output/%x-%j.out        ## stdout, with job name and id in the filename
#SBATCH --error=output/%x-%j.err         ## stderr, with job name and id in the filename
#SBATCH --partition=compute_zone2,normal ## Slurm partitions to use
#SBATCH --nodes=2                        ## Number of nodes to run on
#SBATCH --ntasks-per-node=2              ## Number of MPI processes to start on each node
#SBATCH --cpus-per-task=1                ## Cores allocated for each process
#SBATCH --time=00:05:00

# Start from a clean module environment and load the compiler and MPI by
# name (no version numbers) so the job picks up what is installed on the
# node it runs on.
module purge
module load gnu12 openmpi4

# mpirun reads the node list and task count from the Slurm allocation and
# starts one copy of ./ring per task (here 2 nodes x 2 tasks = 4).
mpirun ./ring
