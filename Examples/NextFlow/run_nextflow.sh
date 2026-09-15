#!/bin/bash

#SBATCH --job-name=nextflow
#SBATCH --output=output/nextflow.out
#SBATCH --error=output/nextflow.err
#SBATCH --partition=compute_zone2,normal
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=02:00:00

# Run the Nextflow controller as a small Slurm job.  It submits the workflow's
# processes as further Slurm jobs (see nextflow.config) and must outlive them.
eval "$(${HOME}/miniconda3/bin/conda shell.bash hook)"
conda activate nextflow

${HOME}/bin/nextflow run hello.nf
