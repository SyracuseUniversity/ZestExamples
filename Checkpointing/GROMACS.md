# GROMACS Checkpointing on Slurm (basic example)

This example uses GROMACS .cpt checkpoints and resumes with -cpi if a checkpoint exists. General details about Slurm checkpoing can be found on the [main checkpoiting page](https://github.com/SyracuseUniversity/ZestExamples/tree/main/Checkpointing). 

## Example SBATCH (gmx_mdrun.sbatch)  

```bash
#!/bin/bash
#SBATCH -J gmx_md
#SBATCH -A your_account
#SBATCH -p your_partition
#SBATCH -N 1
#SBATCH --gpus=1           # remove if CPU-only
#SBATCH -n 8               # or use -c for threads
#SBATCH -t 24:00:00
#SBATCH --signal=B:USR1@180   # optional, gives time before timeout

module load gromacs         # or: source ~/miniforge3/etc/profile.d/conda.sh && conda activate gromacs
# If your site uses MPI GROMACS: replace the last line with 'srun gmx_mpi mdrun ...'

# Resume if a checkpoint exists
CPI=""
[ -f md.cpt ] && CPI="-cpi md.cpt"

# Run (assumes md.tpr is present in the working directory)
gmx mdrun -deffnm md \
          -cpt 15 -cpo md.cpt ${CPI} \
          -append \
          -maxh 23.7
```  

## Notes  

- cpt <minutes> writes periodic checkpoints.  
- cpo md.cpt writes the checkpoint; -cpi md.cpt resumes if it exists.  
- append continues logs/trajectories in the same files.  
- maxh stops cleanly before walltime so a final checkpoint is written.  
- Keep checkpoints on shared/durable storage (not node-local temp).  
- Make sure md.tpr exists (e.g., via gmx grompp -f mdp.mdp -c conf.gro -p topol.top -o md.tpr).  

## How to confirm it works  

- sbatch gmx_mdrun.sbatch and let it run long enough to create md.cpt.  
- Stop the job (scancel <jobid>) or let the time limit hit.  
- Submit the same script again — it detects md.cpt and continues.  
