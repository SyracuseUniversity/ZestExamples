# PyTorch

PyTorch is a large, complex toolkit with a lot of dependencies.  Installing it
from the `pytorch` Conda channel has tended to be unstable, so we recommend
either the [uv](../uv) package manager, which handles PyTorch particularly
well, or a Conda environment with PyTorch installed by `pip` as described
here.  Both approaches bring in the NVIDIA CUDA libraries automatically as
ordinary Python packages, there is no need to load the `cuda` module.


## Installing Conda

To install Conda:

```bash
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"

bash Miniforge3-$(uname)-$(uname -m).sh -b -p $HOME/miniconda3
eval "$(${HOME}/miniconda3/bin/conda shell.bash hook)"
conda init
```

In order to make Conda available automatically when you log into the cluster
you will also need to add the following to your `~/.bash_profile`

```bash
if [ -e ${HOME}/.bashrc ]
then
    source ${HOME}/.bashrc
fi
```

Here is some information on
[the difference between bashrc and bash_profile](https://linuxize.com/post/bashrc-vs-bash-profile/)


After making these changes log out and log back in.


## Installing PyTorch and other packages

Once Conda has been set up create an environment and install PyTorch with

```bash
conda create -n pytorch python=3.12 pip
conda activate pytorch
python3 -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
```

The `--index-url` part matters.  A plain `pip install torch` currently gives
a build for CUDA 13, which needs a newer NVIDIA driver than Zest's GPU nodes
have (driver 545, CUDA 12.3), and PyTorch then silently falls back to the
CPU with a warning in the error file that "The NVIDIA driver on your system
is too old".  The CUDA 12.6 build works with Zest's driver.  See the
[PyTorch site](https://pytorch.org/get-started/locally/) for the current
list of builds.

The download is large (a few gigabytes including the CUDA libraries) so this
takes a few minutes.  After activating the pytorch environment you can install
any additional packages you may need, for example

```bash
conda install scipy
```

It's worth reading through the
[Conda users guide](https://docs.conda.io/projects/conda/en/latest/user-guide/index.html).  Some useful commands are

  * `conda list` lists all installed packages
  * `conda search` finds available packages that match the provided name, for
    example `conda search torch` will find all available versions of `torch`,
    `pytorch` etc
  * `conda update` updates packages


## Running the PyTorch example

This directory contains a simple example `pytorch_demo.py` that reports on the available devices
and performs a simple calculation.  To run it on a GPU on the cluster


```bash
sbatch pytorch_demo.sh
```

After submitting you can check on the progress with

```bash
squeue --me
```

or monitor it with

```bash
watch -n 5 squeue --me
```

When it completes you can check the output with

```bash
cat output/pytorch_demo.out
```

The first line should be `Using GPU`.  If it says `Using CPU` instead, check
`output/pytorch_demo.err`: a "driver too old" warning means the CUDA 13
build was installed, reinstall with the `--index-url` above; no warning at
all usually means the `--gres` line is missing from the batch script.

## The batch script

Note that `pytorch_demo.sh` does not simply call `python3 pytorch_demo.py`.
Batch jobs start in a fresh shell where Conda has not been set up, so the
script first enables the `conda` command and activates the `pytorch`
environment.  For most simple applications you should be able to modify the
final line without changing anything else.


## Requesting a GPU

The batch script contains

```
#SBATCH --partition=gpu_zone2,gpu
#SBATCH --gres=gpu:1
```

The first line restricts the job to the two partitions that contain GPUs
(letting Slurm pick whichever has room first) and the second asks for one GPU
on that node.  Without `--gres` the job would run on a GPU node without
access to any GPU and PyTorch would report `Using CPU`.  Zest's GPU nodes each
have four NVIDIA A40 GPUs (46 GB each, compute capability 8.6), which PyTorch
supports out of the box, and you can ask for up to four with `--gres=gpu:4`
if your code can use them.

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
