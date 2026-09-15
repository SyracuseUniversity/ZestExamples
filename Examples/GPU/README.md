# GPU

This example demonstrates how to submit a very simple job to the GPU partitions, `gpu` and
`gpu_zone2`, on the Zest cluster.  It requests a single GPU, prints basic job information,
displays GPU details with `nvidia-smi`, and reports the CUDA compiler version.  It is a good
first job to run before trying [tensorflow](../tensorflow), [PyTorch](../PyTorch) or any other
GPU code, because it confirms that your job is actually being given a GPU.

## Zest's GPUs

Both GPU partitions contain nodes with four NVIDIA A40 GPUs (46 GB memory each, compute
capability 8.6) and NVIDIA driver 545, which supports CUDA 12.3.  A job may request up to
four GPUs on a single node if your code can use them.  Code that needs CUDA 13 can still run,
see the [CUDA 13](../CUDA13) notes.

## Requesting a GPU

The two essential lines in `hello_gpu.sh` are

```bash
#SBATCH --partition=gpu_zone2,gpu   # Slurm will use whichever partition has room first
#SBATCH --gres=gpu:1                # Adjust up to 4 if your code can take advantage
```

Without `--gres` a job can land on a GPU node but will not be able to see any GPU, which
typically shows up as code silently running on the CPU.  Slurm sets `CUDA_VISIBLE_DEVICES`
so that your program sees only the GPU(s) allocated to it, so from the program's point of
view the first GPU is always device 0.

The `cuda` module provides the `nvcc` compiler and CUDA libraries for code that needs
them.  Python packages such as PyTorch and Tensorflow bring their own CUDA libraries and
do not need the module.

## Running the sample job

```bash
sbatch hello_gpu.sh
```

After submitting you can check on the progress with

```bash
squeue --me
```

When it completes you can check the output with

```bash
cat output/hello_gpu.out
```

Your output should look similar to the [example output](hello_gpu.out), the important
parts are `Allocated GPUs: 1` and an `nvidia-smi` table listing an A40.

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
