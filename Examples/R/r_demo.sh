#!/bin/bash

#SBATCH --job-name=r_demo
#SBATCH --output=output/r_demo.out
#SBATCH --error=output/r_demo.err
#SBATCH --partition=compute_zone2,normal
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:10:00

eval "$(${HOME}/miniconda3/bin/conda shell.bash hook)"
conda activate r

Rscript r_demo.R
