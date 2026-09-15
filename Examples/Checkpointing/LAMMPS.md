# LAMMPS Checkpointing on Slurm (basic example)

This example uses LAMMPS `restart` files and resumes with `read_restart`.
General details about checkpointing on Slurm can be found on the [main checkpointing page](README.md).

LAMMPS is not installed centrally on Zest, the simplest way to get it is
through Conda (see the [python](../python) example for installing Conda):

```bash
conda create -n lammps-mpi -c conda-forge lammps mpich mpi4py
```

## Example batch script (`lammps.sh`)

```bash
#!/bin/bash
#SBATCH --job-name=lmp_mpi
#SBATCH --partition=compute_zone2,normal
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --cpus-per-task=1
#SBATCH --time=08:00:00
#SBATCH --output=lmp_%j.out
#SBATCH --error=lmp_%j.err

eval "$(${HOME}/miniconda3/bin/conda shell.bash hook)"
conda activate lammps-mpi

# The Conda build of LAMMPS uses Conda's own MPICH, so launch it with that
# MPICH's mpiexec (found on the path once the environment is active) rather
# than srun.  Keep the job on one node.
mpiexec -n ${SLURM_NTASKS} lmp -in in.md
```

## Input file (`in.md`)

```bash
# Read initial system OR resume from a restart file (choose one):
# read_data       data.system
# read_restart    restart.somefile.bin

# Write periodic restarts (example: every 10k steps)
restart 10000 restart.*.bin

# ... your usual settings (pair_style, neighbor, fixes, etc.) ...

thermo 1000
run    200000
```

## Notes

- To resume, set `read_restart` to the specific restart file you want to continue from.
- Keep restart files on the shared home filesystem.
- To have the same input work for both the first run and restarts, LAMMPS
  supports `if` on the command line, for example
  `lmp -in in.md -var restart $(ls restart.*.bin 2>/dev/null | tail -1)` with
  the input choosing `read_restart` when the variable is set.  See the
  [LAMMPS restart documentation](https://docs.lammps.org/restart.html).

## How to confirm it works

- Launch with `read_data` and `restart 10000 ...`.  Let it run until a `restart.*.bin` appears.
- Stop the job (`scancel <jobid>`).
- Edit `in.md` to use `read_restart restart.<timestamp>.bin` (and comment out `read_data`), then submit again — it continues from the saved state.

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
