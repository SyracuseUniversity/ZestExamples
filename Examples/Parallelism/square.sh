#!/bin/bash

#SBATCH --job-name=square
#SBATCH --output=output/square_%a.out
#SBATCH --error=output/square_%a.err
#SBATCH --partition=compute_zone2,normal
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00

# One task per value.  The values are passed in through the VALUES environment
# variable (space separated) and each task picks out its own with the task ID.
read -r -a values <<< "$VALUES"
python3 square.py "${values[$SLURM_ARRAY_TASK_ID]}"
