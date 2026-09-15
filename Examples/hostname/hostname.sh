#!/bin/bash

#SBATCH --job-name=hostname
#SBATCH --output=output/hostname.out
#SBATCH --error=output/hostname.err
#SBATCH --partition=compute_zone2,normal
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00

/bin/hostname
