# CUDA 13

Increasingly packages and libraries are written against the latest CUDA version,
[CUDA 13](https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html).
However, CUDA 13 requires a recent version of the NVIDIA kernel drivers.  Zest's
GPU nodes currently run driver 545, which supports CUDA up to 12.3.

Until the drivers can be upgraded there is a [compatibility
library](https://docs.nvidia.com/deploy/cuda-compatibility/latest/) that will
allow code needing CUDA 13 to run.  It works only on data center GPUs, which
includes all of Zest's GPUs (NVIDIA A40, compute capability 8.6).

Before going down this route check whether the package you need also
publishes a CUDA 12 build.  PyTorch, Tensorflow and JAX all do, and those
work on Zest with no extra steps, see the [PyTorch](../PyTorch),
[tensorflow](../tensorflow) and [JAX](../JAX) examples.


## Installing the library

It is first necessary to have a Conda environment set up, see the
[Python](../python) documentation for information on how to install Conda.

Once Conda is installed, create an environment for CUDA 13 and the compat library:

```bash
eval "$(${HOME}/miniconda3/bin/conda shell.bash hook)"

conda create -n cuda13
conda activate cuda13
conda install -c nvidia cuda cuda-compat
```

You will also need to set an environment variable to ensure that the
compatibility layer is found, both when testing interactively and inside the
batch script:

```bash
export LD_LIBRARY_PATH=${HOME}/miniconda3/envs/cuda13/cuda-compat:${LD_LIBRARY_PATH}
```

After that it should be possible to run packages needing CUDA 13 as well as
compile them using `nvcc`.  A quick check is

```bash
nvidia-smi
```

run from inside a GPU job, the `CUDA Version` shown in the top right corner
should now read 13.x rather than 12.3.


## Running on the cluster

No special Slurm options are needed beyond the usual GPU request, since every
GPU on Zest supports the compatibility library

```
#SBATCH --partition=gpu_zone2,gpu
#SBATCH --gres=gpu:1
```

Remember to put the `LD_LIBRARY_PATH` line in the batch script after
activating the environment.

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
