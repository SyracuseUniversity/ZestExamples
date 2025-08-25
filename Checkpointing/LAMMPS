# LAMMPS Checkpointing on Slurm (Basic Example)  

This example uses LAMMPS `restart` files and resumes with `read_restart`. General details about Slurm checkpoing can be found on the [main checkpoiting page](https://github.com/SyracuseUniversity/ZestExamples/tree/main/Checkpointing). 

## Example SBATCH (`lammps.sbatch`)  

```bash
#!/bin/bash
#SBATCH -J lmp_md
#SBATCH -A your_account
#SBATCH -p your_partition
#SBATCH -n 32
#SBATCH -t 08:00:00
#SBATCH --signal=B:USR1@120   # optional, gives a little time before timeout

module load lammps     # or conda activate lammps

# Use srun if your site prefers it; adjust executable name (lmp, lmp_mpi, ...)
srun -n ${SLURM_NTASKS} lmp -in in.md
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
