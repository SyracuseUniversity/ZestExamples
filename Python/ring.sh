#!/bin/bash

#SBATCH -e output/ring.err
#SBATCH -o output/ring.out
#SBATCH --partition=normal
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1

eval "$(/home/$(whoami)/miniconda3/bin/conda shell.bash hook)"

mpirun ./ring.py

