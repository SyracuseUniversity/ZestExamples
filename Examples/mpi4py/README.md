# MPI in Python

This is a Python example based on one from this
[MPI with Python presentation](https://cloudmesh.github.io/cloudmesh-mpi/report-mpi.pdf).
This example creates a number of processes that communicate over MPI and pass a
simple message around the processes in a ring.  See the presentation for more
details, and the [MPI](../MPI) example for the same thing in C along with some
background on MPI on Zest.

To run it you'll first need to install Python and the mpi4py library.


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


## Install mpi4py

This is the one step where mpi4py differs from most Python packages.  If you
simply `conda install mpi4py`, Conda will also install its own copy of MPI,
which knows nothing about Slurm or Zest's network and will not work across
nodes.  Instead, build mpi4py against the OpenMPI that Zest provides.  Create
an environment with Python and pip, then have pip compile mpi4py using the
system `mpicc`

```bash
conda create -n mpi4py python=3.12 pip
conda activate mpi4py
MPICC=$(which mpicc) pip install --no-binary mpi4py mpi4py
```

`which mpicc` should print `/opt/ohpc/pub/mpi/openmpi4-gnu12/4.1.6/bin/mpicc`,
if it prints something under your home directory another environment with
MPI in it is active, run `conda deactivate` until it doesn't.  The build takes
a minute or so.  You can check that it picked up the right library with

```bash
python3 -c "from mpi4py import MPI; print(MPI.Get_library_version())"
```

which should mention `Open MPI v4.1.6`.

It's worth reading through the
[Conda users guide](https://docs.conda.io/projects/conda/en/latest/user-guide/index.html).  Some useful commands are

  * `conda list` lists all installed packages
  * `conda search` finds available packages that match the provided name
  * `conda update` updates packages


## Running the sample program

After installing you can submit the program to the cluster with

```bash
sbatch ring.sh
```

You can then check the status of your job with

```bash
squeue --me
```

The job should move from the PD (pending) state to the R (running) state and
then complete, although this may happen too fast to notice.  If `squeue`
reports no jobs then it has completed.  Check the output with

```bash
cat output/ring.out
```

## The batch script

`ring.sh` loads the system MPI, activates the Conda environment and then
starts the program with `mpirun`

```bash
module purge
module load gnu12 openmpi4

eval "$(${HOME}/miniconda3/bin/conda shell.bash hook)"
conda activate mpi4py

mpirun python3 ring.py
```

`mpirun` starts one Python process for each task in the allocation (two nodes
times two tasks per node, so four in total) and connects them with MPI.  As
explained in the [MPI](../MPI) example, use `mpirun` rather than `srun` to
start MPI programs on Zest, and load modules inside the batch script by
name, without version numbers, after a `module purge`.

One thing to watch for: if `mpirun` runs but every process reports
`Communicator group with 1 processes`, a Conda `mpirun` is being used instead
of the system one.  `which mpirun` inside the job should print a path under
`/opt/ohpc`, if it doesn't, use `$MPI_DIR/bin/mpirun` in the script.

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
