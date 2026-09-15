#!/bin/bash

#SBATCH --job-name=ring
#SBATCH --output=output/ring.out
#SBATCH --error=output/ring.err
#SBATCH --partition=compute_zone2,normal
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00

# Start from a clean module environment and load the compiler and MPI by
# name (no version numbers) so the job picks up what is installed on the
# node it runs on.
module purge
module load gnu12 openmpi4

# Enable conda in this non-interactive shell and activate the environment
# that has mpi4py installed.
eval "$(${HOME}/miniconda3/bin/conda shell.bash hook)"
conda activate mpi4py

# mpirun starts one Python process per task (2 nodes x 2 tasks = 4) and
# connects them with MPI.
mpirun python3 ring.py
