#!/bin/bash

#SBATCH --job-name=snakemake
#SBATCH --output=output/snakemake.out
#SBATCH --error=output/snakemake.err
#SBATCH --partition=compute_zone2,normal
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --time=02:00:00

# Run the Snakemake controller itself as a (small, long-lived) Slurm job.  It
# submits one further Slurm job per rule and waits for them, so this job needs
# very little CPU but must outlive the whole workflow.
eval "$(${HOME}/miniconda3/bin/conda shell.bash hook)"
conda activate snakemake

# --latency-wait: files written by a job on one node can take a little while to
# become visible on another, give them up to 60 seconds before declaring failure.
snakemake --executor slurm --jobs 5 --latency-wait 60 sum_of_squares.txt
