# Python

This is a simple example of running a basic Python program under Slurm.  This example uses a
single CPU and can serve as a template for Python programs that may require some specialized
packages but do not need a GPU.  For GPU examples, please see the [tensorflow](../tensorflow) and
[PyTorch](../PyTorch) directories.

Zest does provide a system Python and an `anaconda3` module, but these are shared and can't be
modified, so any program that needs packages beyond the standard library should use its own
environment as described here.


## Installing Conda

For most Python users we recommend installing [Conda](https://github.com/conda-forge/miniforge) and
using that to manage your environment.  To install Conda:

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

We recommend Miniforge specifically, rather than Anaconda or Miniconda,
because it only uses the community `conda-forge` channel.  Installations
that include Anaconda's `defaults` channel now stop with a "Terms of Service
have not been accepted" error when creating environments, if you already have
one of those and see that message, either accept the terms as the message
describes or add `--override-channels -c conda-forge` to `conda create`.


## Create an environment and install packages

It is a good idea to keep each project in its own environment rather than
installing everything into Conda's `base`.  To create one called `python` and
install numpy into it

```bash
conda create -n python python=3.12
conda activate python
conda install numpy
```

It's worth reading through the
[Conda users guide](https://docs.conda.io/projects/conda/en/latest/user-guide/index.html).  Some useful commands are

  * `conda env list` lists your environments
  * `conda list` lists all installed packages in the active environment
  * `conda search` finds available packages that match the provided name, for
    example `conda search torch` will find all available versions of `torch`,
    `pytorch` etc
  * `conda update` updates packages


## Running the sample program

This directory contains a sample program `python_demo.py` which simply adds the
numbers from 1 to 100 and prints the result.  To submit this to the cluster the command is

```bash
sbatch python_demo.sh
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
cat output/python_demo.out
```

## The batch script

Note that `python_demo.sh` does not simply call `python3 python_demo.py`.  Batch
jobs start in a fresh, non-interactive shell where the `conda` command has not
been set up, so the script first runs the same `shell.bash hook` line used
during installation and then activates the environment:

```bash
eval "$(${HOME}/miniconda3/bin/conda shell.bash hook)"
conda activate python

python3 python_demo.py
```

For most simple Python applications you should be able to change the
environment name and the final line without touching the `#SBATCH` lines.  If
a job fails with `ModuleNotFoundError` the first thing to check is that it is
activating the environment where the package was installed.

## What to read next

There are also documents on how to [parallelize](../Parallelism) code to make optimal use of the cluster
and how to use specialized [file formats](../FileManagement) to optimize data storage and access.

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
