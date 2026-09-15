# R

This is a simple example of running a basic R program under Slurm.  This example uses a
single CPU and can serve as a template for R programs that may require some specialized
packages but do not need a GPU.  R is not installed system-wide on Zest, so the
first step is to install it in your home directory.


## Installing Conda

For most R users we recommend installing R through [Conda](https://github.com/conda-forge/miniforge) and
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


## Install R and additional packages

You can now use the `conda` command to create an environment containing R:

```bash
conda create -n r conda-forge::r-base
conda activate r
```

Many R packages are also available through Conda with an `r-` prefix, for
example `conda install conda-forge::r-tidyverse`, which is usually faster and
more reliable than `install.packages()` because Conda brings along any
compiled libraries the package needs.  It's worth reading through the
[Conda users guide](https://docs.conda.io/projects/conda/en/latest/user-guide/index.html).  Some useful commands are

  * `conda list` lists all installed packages
  * `conda search` finds available packages that match the provided name, for
    example `conda search r-ggplot2`
  * `conda update` updates packages


## Running the sample program

This directory contains a sample program `r_demo.R` which simply adds the
numbers from 1 to 100 and prints the result.  To submit this to the cluster the command is

```bash
sbatch r_demo.sh
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
cat output/r_demo.out
```

## The batch script

Note that `r_demo.sh` does not simply call `Rscript r_demo.R`.  Batch jobs
start in a fresh shell where Conda has not been set up, so the script first
enables the `conda` command and activates the environment:

```bash
eval "$(${HOME}/miniconda3/bin/conda shell.bash hook)"
conda activate r

Rscript r_demo.R
```

For most simple R applications you should be able to modify the final line
without changing anything else.

## What to read next

There are also documents on how to [parallelize](../Parallelism) code to make optimal use of the cluster
and how to use specialized [file formats](../FileManagement) to optimize data storage and access.

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
