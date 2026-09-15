#!/bin/bash

#SBATCH --job-name=example
#SBATCH --output=example.out
#SBATCH --error=example.err
#SBATCH --partition=gpu_zone2,gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=00:10:00

# uv installs itself into ~/.local/bin, which may not be on the PATH inside a
# batch job, so give the full path.  uv sets up the project environment itself,
# there is nothing to activate.
${HOME}/.local/bin/uv run example.py
