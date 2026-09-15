#!/bin/bash

#SBATCH --job-name=hello_gpu
#SBATCH --output=output/hello_gpu.out
#SBATCH --error=output/hello_gpu.err
#SBATCH --partition=gpu_zone2,gpu   # Slurm will use whichever partition has room first
#SBATCH --gres=gpu:1                # Adjust up to 4 if your code can take advantage
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=00:05:00

echo "===== SLURM Job Info ====="
echo "Job ID: $SLURM_JOB_ID"
echo "Job Name: $SLURM_JOB_NAME"
echo "Node List: $SLURM_JOB_NODELIST"
echo "Allocated GPUs: $SLURM_GPUS_ON_NODE"
echo "CUDA_VISIBLE_DEVICES: $CUDA_VISIBLE_DEVICES"
echo "=========================="

# Load CUDA module (provides nvcc and the CUDA libraries)
module load cuda

# Show GPU details
echo "===== GPU Info ====="
nvidia-smi
echo "===================="

# Confirm the CUDA compiler is available
echo "===== CUDA Test ====="
nvcc --version
echo "===================="
