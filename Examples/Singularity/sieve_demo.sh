#!/bin/bash

#SBATCH --job-name=sieve_demo
#SBATCH --output=output/sieve_demo.out
#SBATCH --error=output/sieve_demo.err
#SBATCH --partition=compute_zone2,normal
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:10:00

# The singularity module is loaded by default on Zest, this line is just insurance.
module load singularity

echo "Using $(which singularity), $(singularity --version)"

# Compile and then run the Haskell program using the compiler inside the container.
singularity exec haskell_latest.sif ghc sieve.hs -o sieve
singularity exec haskell_latest.sif ./sieve
