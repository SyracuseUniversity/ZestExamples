#!/bin/bash

#SBATCH --job-name=pytorch_demo
#SBATCH --output=output/pytorch_demo.out
#SBATCH --error=output/pytorch_demo.err
#SBATCH --partition=gpu_zone2,gpu
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=00:10:00

eval "$(${HOME}/miniconda3/bin/conda shell.bash hook)"
conda activate pytorch

python3 pytorch_demo.py
