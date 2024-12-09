#!/bin/bash

#SBATCH --job-name=ring  ##Name of job
#SBATCH --error=output/%x-%j.err  ##stderr for job with job name and id in the filename
#SBATCH --output=output/%x-%j.out  ##stdout output for job with job name and id in the filename

#SBATCH --partition=compute_zone2,normal  ##Slurm partitions to use
#SBATCH --nodes=4  ##Number of nodes to run on
#SBATCH --ntasks-per-node=1 ##Number of tasks to be launched per node
#SBATCH --cpus-per-task=1  ##Cores allocated for each task in a job

mpirun ring  ##Launch the MPI application across a set of allocated nodes in the cluster
