#!/bin/bash

#SBATCH --job-name=ollama_app
#SBATCH --output=output/ollama_app.out
#SBATCH --error=output/ollama_app.err
#SBATCH --partition=gpu_zone2,gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=00:30:00

module load singularity

# Where ollama keeps downloaded models.  Keeping this in your home directory
# means a model only has to be pulled once, after that every job can reuse it.
export OLLAMA_MODELS=${HOME}/.ollama/models
mkdir -p ${OLLAMA_MODELS}

MODEL=llama3.2:1b
SIF=ollama_0.6.8.sif     # see the readme for why this version is pinned

# --nv makes the GPU visible inside the container.  Start the server in the
# background (setsid puts it in its own process group so it can be stopped
# cleanly below), give it a moment to come up, then send it the prompt.
setsid singularity exec --nv ${SIF} ollama serve > output/serve.out 2>&1 &
SERVE_PID=$!
sleep 15

singularity exec --nv ${SIF} ollama run ${MODEL} < input/prompt.txt
echo

# Stop the server, otherwise the job keeps running until its time limit.
# Killing just the singularity wrapper is not enough, the whole group must go.
kill -- -${SERVE_PID}
sleep 5
kill -9 -- -${SERVE_PID} 2>/dev/null
exit 0
