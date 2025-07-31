#!/bin/bash
#SBATCH --job-name=hello_gpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpu_zone2,gpu # will prioritize gpu_zone2 and move to gpu if zone2 is full
#SBATCH --gres=gpu:1 # Adjust up to 4 if your script/code can take advantage
#SBATCH --time=00:02:00
#SBATCH --output=hello_gpu_%j.out
#SBATCH --error=hello_gpu_%j.err

echo "===== SLURM Job Info ====="
echo "Job ID: $SLURM_JOB_ID"
echo "Job Name: $SLURM_JOB_NAME"
echo "Node List: $SLURM_JOB_NODELIST"
echo "Allocated GPUs: $SLURM_GPUS_ON_NODE"
echo "=========================="

# Load CUDA module
module load cuda

# Show GPU details
echo "===== GPU Info ====="
nvidia-smi
echo "===================="

# Run a simple CUDA device query to confirm functionality
echo "===== CUDA Test ====="
nvcc --version
echo "===================="
