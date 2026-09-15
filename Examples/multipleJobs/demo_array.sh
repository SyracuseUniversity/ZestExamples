#!/bin/bash

#SBATCH --job-name=demo
#SBATCH --output=output/demo_%a.out
#SBATCH --error=output/demo_%a.err
#SBATCH --partition=compute_zone2,normal
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00
#SBATCH --array=1-5

# Slurm sets SLURM_ARRAY_TASK_ID to 1, 2, 3, 4 or 5 in each copy of this job.
# Use it to pick one line out of demo.dat and split that line into arguments.
line=$(sed -n "${SLURM_ARRAY_TASK_ID}p" demo.dat)
read -r arg1 arg2 <<< "$line"

./demo.sh "$arg1" "$arg2"
