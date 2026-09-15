#!/bin/bash

#SBATCH --job-name=gromacs_example
#SBATCH --output=output/gromacs_example_%j.out
#SBATCH --error=output/gromacs_example_%j.err
#SBATCH --partition=gpu_zone2,gpu
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=00:10:00

# Start from a clean module environment and load the compiler, MPI and
# GROMACS (CUDA enabled, thread-MPI build) by name, without version numbers.
module purge
module load gnu12 openmpi4 gromacs

# Run the tiny test simulation.  -nb gpu puts the non-bonded work on the GPU,
# -ntmpi 1 -ntomp N runs one rank with all the CPU cores the job was given.
gmx mdrun -s small_test.tpr -nsteps 5000 -nb gpu \
    -ntmpi 1 -ntomp ${SLURM_CPUS_PER_TASK} -deffnm output/small_test
