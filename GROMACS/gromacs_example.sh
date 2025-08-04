#!/bin/bash
#SBATCH --job-name=gromacs_example
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --partition=gpu_zone2,gpu
#SBATCH --gres=gpu:1
#SBATCH --time=00:02:00
#SBATCH --output=gromacs_example_%j.out
#SBATCH --error=gromacs_example_%j.err

# Load required modules
module load gromacs

# Run the tiny test simulation
gmx mdrun -s small_test.tpr -nsteps 5000 -nb gpu
