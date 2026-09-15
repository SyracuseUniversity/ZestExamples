#!/bin/bash

#SBATCH --job-name=python_demo
#SBATCH --output=output/python_demo.out
#SBATCH --error=output/python_demo.err
#SBATCH --partition=compute_zone2,normal
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:10:00

# Make the conda command available to this (non-interactive) shell,
# then activate the environment the program needs.
eval "$(${HOME}/miniconda3/bin/conda shell.bash hook)"
conda activate python

python3 python_demo.py
