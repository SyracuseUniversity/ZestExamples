#!/bin/bash

#SBATCH --job-name=octave_demo
#SBATCH --output=output/octave_demo.out
#SBATCH --error=output/octave_demo.err
#SBATCH --partition=compute_zone2,normal
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:10:00

eval "$(${HOME}/miniconda3/bin/conda shell.bash hook)"
conda activate octave

octave --no-gui octave_demo.m
