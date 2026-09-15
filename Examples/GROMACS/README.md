# GROMACS

This example demonstrates running a **very small** [GROMACS](https://www.gromacs.org/)
molecular dynamics job on Zest's GPU nodes.  The simulation is a tiny water box, pre-built
into `small_test.tpr` so no setup steps are required.

Users new to GROMACS are encouraged to review the [official GROMACS
documentation](https://manual.gromacs.org/) and a more complete
[tutorial](http://www.mdtutorials.com/gmx/lysozyme/index.html).

## GROMACS on Zest

GROMACS 2023.2 is installed centrally and made available with

```bash
module load gromacs
```

This is a CUDA-enabled build using GROMACS' built-in thread-MPI, so a single
`gmx mdrun` can use all the cores and GPUs of one node.  For runs spanning
several nodes the same module also provides `gmx_mpi`, to be started with
`srun --mpi=pmi2` as in the [MPI](../MPI) example.

As with every module on Zest, load it inside the batch script after a
`module purge`, by name and without version numbers (`gnu12 openmpi4
gromacs`), which is what the example does.  A batch job otherwise inherits
the login shell's environment, and if that does not match the node the job
lands on `gmx` fails at startup with a library error such as
`GLIBCXX_3.4.29 not found`.

## Files

- `gromacs_example.sh` – Slurm batch script for submitting the job.
- `small_test.tpr` – Pre-generated GROMACS run file (tiny water box).

## Running the sample job

```bash
sbatch gromacs_example.sh
```

After submitting you can check on the progress with

```bash
squeue --me
```

The job takes well under a minute once it starts.

## Reviewing the output

GROMACS writes its log to `output/gromacs_example_<jobid>.err` (GROMACS
prints its progress to standard error, which is normal) and the simulation
results into the `output` directory:

- `small_test.gro` – final coordinates
- `small_test.edr` – energies
- `small_test.trr` – trajectory
- `small_test.log` – the detailed run log, including a performance summary at the end

The end of `small_test.log` should report the GPU that was used, for example
`1 GPU selected for this run` followed by `NVIDIA A40`, and a `Performance:`
line in ns/day.

## The batch script

The key lines are

```bash
#SBATCH --partition=gpu_zone2,gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8

module purge
module load gnu12 openmpi4 gromacs
gmx mdrun -s small_test.tpr -nsteps 5000 -nb gpu \
    -ntmpi 1 -ntomp ${SLURM_CPUS_PER_TASK} -deffnm output/small_test
```

`--gres=gpu:1` requests the GPU and `-nb gpu` tells GROMACS to use it for the
non-bonded calculations.  `-ntmpi 1 -ntomp 8` runs a single thread-MPI rank
with eight OpenMP threads, the number of cores Slurm allocated (GROMACS
insists on being told both when a GPU is in use), and `-deffnm` puts all the
output files under `output/` with a common name.  For a production run raise `--time`, drop
`-nsteps` (the number of steps then comes from the `.tpr` file), and see the
[Checkpointing](../Checkpointing/GROMACS.md) example for how to make long runs
restartable.

## Sample TPR methodology

You can generate or provide your own `.tpr` file for testing.

The `.tpr` file included in this repository was generated once and stored here so that it can be run without preparing inputs each time.

Below are the steps and parameters used to create it.

1 - Create a minimal MDP file (`minim.mdp`)
```
integrator  = steep
emtol       = 1000.0
emstep      = 0.01
nsteps      = 500
nstlist     = 1
cutoff-scheme = Verlet
coulombtype = PME
rcoulomb    = 1.0
rvdw        = 1.0
pbc         = xyz
```
2 - Create a small water box
```
module load gromacs
gmx solvate -cs spc216.gro -o water_box.gro -box 3 3 3
```
3 - Generate topology
```
gmx pdb2gmx -f water_box.gro -o processed.gro -p topol.top -water spce
# When prompted, enter '14' for Gromos54a7
```
4 - Generate the .tpr file
```
gmx grompp -f minim.mdp -c processed.gro -p topol.top -o small_test.tpr -maxwarn 1
```
Once generated, `small_test.tpr` can be submitted with the provided Slurm script to run a short GPU test job.

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
