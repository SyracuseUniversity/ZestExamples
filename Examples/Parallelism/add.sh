#!/bin/bash

#SBATCH --job-name=add
#SBATCH --output=output/%x_%j.out
#SBATCH --error=output/%x_%j.err
#SBATCH --partition=compute_zone2,normal
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00

# Add up the numbers found in the files named on the command line.
python3 add.py "$@"
