#!/bin/bash

#SBATCH --job-name=jax_demo
#SBATCH --output=output/jax_demo.out
#SBATCH --error=output/jax_demo.err
#SBATCH --partition=gpu_zone2,gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=00:15:00

eval "$(${HOME}/miniconda3/bin/conda shell.bash hook)"
conda activate jax

python3 jax_demo.py
