#!/bin/bash

#SBATCH -e output/hostname.err
#SBATCH -o output/hostname.out
#SBATCH --partition=compute_zone2,normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1

/bin/hostname

