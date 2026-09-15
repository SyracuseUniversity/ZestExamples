#!/bin/bash

#SBATCH --job-name=julia_demo
#SBATCH --output=output/julia_demo.out
#SBATCH --error=output/julia_demo.err
#SBATCH --partition=compute_zone2,normal
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:20:00

eval "$(${HOME}/miniconda3/bin/conda shell.bash hook)"
conda activate julia

julia julia_demo.jl
