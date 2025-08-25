# LAMMPS Checkpointing on Slurm (Basic Example)  

This example uses LAMMPS `restart` files and resumes with `read_restart`. General details about Slurm checkpoing can be found on the [main checkpoiting page](https://github.com/SyracuseUniversity/ZestExamples/tree/main/Checkpointing). 

## Example SBATCH (`lammps.sbatch`)  

```bash
#!/bin/bash -l
#SBATCH -J lmp_mpi
#SBATCH -p your_partition
#SBATCH -A your_account
#SBATCH -n 32
#SBATCH -t 08:00:00
#SBATCH --signal=B:USR1@120   # optional

# IMPORTANT: do NOT load system OpenMPI when using the conda MPICH build
conda activate lammps-mpi    # env created with: conda create -n lammps-mpi -c conda-forge lammps mpich mpi4py

mpiexec -n ${SLURM_NTASKS} lmp -in in.md
# (mpiexec and mpirun both work with MPICH; use whichever the env provides)
```  

## Input File (in.md)  

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

- To resume, set read_restart to the specific restart file you want to continue from.  
- Keep restart files on shared/durable storage.  

## How to confirm it works  

- Launch with read_data and restart 10000 .... Let it run until a restart.*.bin appears.  
- Stop the job (scancel <jobid>).  
- Edit in.md to use read_restart restart.<timestamp>.bin (and comment out read_data), then submit again — it continues from the saved state.  
