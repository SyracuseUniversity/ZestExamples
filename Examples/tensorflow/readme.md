# Tensorflow

Tensorflow is a large, complex toolkit with a lot of dependencies.  We therefore recommend
installing it into its own [Conda](https://github.com/conda-forge/miniforge) environment.
If you prefer [uv](../uv) the same `pip install` line below works there too.


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


## Installing tensorflow and other packages

Once Conda has been set up install tensorflow with

```bash
eval "$(${HOME}/miniconda3/bin/conda shell.bash hook)"
conda create -n tfgpu python=3.11 pip
conda activate tfgpu
python3 -m pip install 'tensorflow[and-cuda]'
```

The `[and-cuda]` part pulls in the CUDA libraries that Tensorflow needs as
ordinary Python packages, so there is no need to load the `cuda` module or
match versions by hand.  Zest's GPU nodes run NVIDIA driver 545, which
supports CUDA 12.x, if a future Tensorflow release requires CUDA 13 see the
[CUDA 13](../CUDA13) notes.

After activating the `tfgpu`  environment you can install any additional packages you
may need, for example

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


## Running the tensorflow example

This directory contains a simple example `tensorflow_demo.py` that reports on the available devices
and performs a simple tensor calculation.  To run it on a GPU on the cluster


```bash
sbatch tensorflow_demo.sh
```

Note that this batch script includes

```
#SBATCH --partition=gpu_zone2,gpu
#SBATCH --gres=gpu:1
```

The first line restricts the job to the two partitions that contain GPUs
(letting Slurm pick whichever has room first) and the second asks for one GPU
on that node.  Without `--gres` Slurm will run the job on a GPU node but
without giving it access to any GPU, and Tensorflow will silently use the
CPU.  Zest's GPU nodes each have four NVIDIA A40 GPUs (46 GB each), ask for
more with `--gres=gpu:2` and so on if your code can use them.

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
cat output/tensorflow_demo.out
```

The device list at the top of the output should include a line with
`device_type: "GPU"`.  Tensorflow also prints a number of informational
messages to the error file, `output/tensorflow_demo.err`, this is normal.

## The batch script

Note that `tensorflow_demo.sh` does not simply call `python3 tensorflow_demo.py`.
Batch jobs start in a fresh shell where Conda has not been set up, so the
script first enables the `conda` command and activates the `tfgpu`
environment.  For most simple applications you should be able to modify the
final line without changing anything else.

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
