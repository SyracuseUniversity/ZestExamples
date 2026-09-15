# Octave

This is a simple example of running a basic [Octave](https://octave.org/) program under Slurm.
Octave is a free and open source math-oriented language that is largely compatible with
Matlab.  This example uses a single CPU and can serve as a template for Octave programs that
may require some specialized packages but do not need a GPU.


## Installing Conda

For most Octave users we recommend installing [Miniforge](https://github.com/conda-forge/miniforge) and
using that to manage your environment.  To install Miniforge:

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


## Install Octave

You can now use the `conda` command to create an environment containing Octave

```bash
conda create -n octave conda-forge::octave
conda activate octave
```

It's worth reading through the
[Conda users guide](https://docs.conda.io/projects/conda/en/latest/user-guide/index.html).  Some useful commands are

  * `conda list` lists all installed packages
  * `conda search` finds available packages that match the provided name
  * `conda update` updates packages

Octave's own packages are installed from inside Octave with `pkg install -forge
<name>`, see the [Octave packages](https://gnu-octave.github.io/packages/) site.


## Running the sample program

This directory contains a sample program `octave_demo.m` which simply adds the
numbers from 1 to 100 and prints the result.  To submit this to the cluster the command is

```bash
sbatch octave_demo.sh
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
cat output/octave_demo.out
```

## The batch script

Note that `octave_demo.sh` does not simply call `octave octave_demo.m`.  Batch
jobs start in a fresh shell where Conda has not been set up, so the script
first enables the `conda` command and activates the environment

```bash
eval "$(${HOME}/miniconda3/bin/conda shell.bash hook)"
conda activate octave

octave --no-gui octave_demo.m
```

For most simple Octave applications you should be able to modify the final
line without changing anything else.

## What to read next

There are also documents on how to [parallelize](../Parallelism) code to make optimal use of the cluster
and how to use specialized [file formats](../FileManagement) to optimize data storage and access.

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
