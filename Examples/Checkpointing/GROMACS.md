# GROMACS Checkpointing on Slurm (basic example)

This example uses GROMACS `.cpt` checkpoints and resumes with `-cpi` if a checkpoint exists.
General details about checkpointing on Slurm can be found on the [main checkpointing page](README.md),
and a small runnable GROMACS job is in the [GROMACS example](../GROMACS).

## Example batch script (`gmx_mdrun.sh`)

```bash
#!/bin/bash
#SBATCH --job-name=gmx_md
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1              # remove if CPU-only
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=24:00:00
#SBATCH --output=gmx_md_%j.out
#SBATCH --error=gmx_md_%j.err

module purge
module load gnu12 openmpi4 gromacs

# Resume if a checkpoint exists
CPI=""
[ -f md.cpt ] && CPI="-cpi md.cpt"

# Run (assumes md.tpr is present in the working directory)
gmx mdrun -deffnm md \
          -ntmpi 1 -ntomp ${SLURM_CPUS_PER_TASK} \
          -cpt 15 -cpo md.cpt ${CPI} \
          -append \
          -maxh 23.7
```

## Notes

- `-cpt <minutes>` writes periodic checkpoints.
- `-cpo md.cpt` writes the checkpoint; `-cpi md.cpt` resumes if it exists.
- `-append` continues logs/trajectories in the same files.
- `-maxh` stops cleanly before walltime so a final checkpoint is written.  Set it a little
  below the `--time` limit (here 23.7 hours against a 24 hour limit).
- Keep checkpoints on the shared home filesystem (not node-local `/tmp`).
- Make sure `md.tpr` exists (e.g., via `gmx grompp -f md.mdp -c conf.gro -p topol.top -o md.tpr`).

## Chaining runs automatically

A simulation that needs several days can be run as a chain of 24 hour jobs,
each one submitted to start after the previous one ends and resuming from its
checkpoint:

```bash
first=$(sbatch --parsable gmx_mdrun.sh)
second=$(sbatch --parsable --dependency=afterany:$first gmx_mdrun.sh)
third=$(sbatch --parsable --dependency=afterany:$second gmx_mdrun.sh)
```

## How to confirm it works

- `sbatch gmx_mdrun.sh` and let it run long enough to create `md.cpt`.
- Stop the job (`scancel <jobid>`) or let the time limit hit.
- Submit the same script again — it detects `md.cpt` and continues.

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
