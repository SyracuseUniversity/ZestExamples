#!/bin/bash

#SBATCH --job-name=tensorflow_demo
#SBATCH --output=output/tensorflow_demo.out
#SBATCH --error=output/tensorflow_demo.err
#SBATCH --partition=gpu_zone2,gpu
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=00:10:00

eval "$(${HOME}/miniconda3/bin/conda shell.bash hook)"
conda activate tfgpu

python3 tensorflow_demo.py
