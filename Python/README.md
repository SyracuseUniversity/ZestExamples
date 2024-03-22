# MPI in Python 

This is a Python example based on one from this
[MPI with Python presentation](https://cloudmesh.github.io/cloudmesh-mpi/report-mpi.pdf). 
This example creates a number of processes that communicate over MPI and pass a
simple message around the processes in a ring.  See the presentation for more
details.

To run it you'll first need to install Python and the mpi4py library.


## Installing Conda

For most Python users we recommend installing [Conda](https://docs.conda.io/en/latest/) and
using that to manage your environment.  To install Conda:

```bash
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh

bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3
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


## Install additional packages

You can now use the `conda` command to install additional packages you'll need.
For example to install numpy

```bash
conda install mpi4py
```

It's worth reading through the
[Conda users guide](https://docs.conda.io/projects/conda/en/latest/user-guide/index.html).  Some useful commands are

  * `conda list` lists all installed packages
  * `conda search` finds available packages that match the provided name, for
    example `conda search torch` will find all avaialable versions of `torch`,
    `pytorch` etc
  * `conda update` updates packages


## Running the sample program

After installing you can submit the program to the cluster with

```bash
sbatch ring.sh
```

You can then check the status of your job with

```bash
squeue -u netid
```

(replace "netid" with your SU netID).  The job should move from the PD
(pending) state to the R (run) state and then complete, although this may
happen too fast to notice.  If `squeue` reports that you have no jobs then it
has completed.  Check the output with

```bash
cat output/ring.out
```



