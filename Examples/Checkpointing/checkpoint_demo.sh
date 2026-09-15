#!/bin/bash

#SBATCH --job-name=checkpoint_demo
#SBATCH --output=output/checkpoint_demo_%j.out
#SBATCH --error=output/checkpoint_demo_%j.err
#SBATCH --partition=compute_zone2,normal
#SBATCH --cpus-per-task=1
#SBATCH --time=00:01:00          # deliberately too short: the program needs ~100 s
#SBATCH --signal=B:USR1@20       # send SIGUSR1 to the batch shell 20 s before the limit
#SBATCH --requeue                # allow the job to be put back in the queue
#SBATCH --open-mode=append       # keep the first run's output when the job runs again

# Forward the warning signal from the batch shell to the Python program.
trap 'kill -USR1 $PID' USR1

python3 checkpoint_demo.py &
PID=$!

# The first 'wait' returns early when the trap fires, so wait again until the
# program has really finished and we have its exit status.
wait $PID
STATUS=$?
while kill -0 $PID 2>/dev/null; do
    wait $PID
    STATUS=$?
done

# Exit code 99 means "I saved a checkpoint but I'm not finished".  Ask Slurm
# to requeue this same job; when it runs again it will resume from the file.
if [ $STATUS -eq 99 ]; then
    echo "Not finished, requeueing job $SLURM_JOB_ID"
    scontrol requeue $SLURM_JOB_ID
fi

exit $STATUS
