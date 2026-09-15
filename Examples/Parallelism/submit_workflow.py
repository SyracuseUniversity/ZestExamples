#!/usr/bin/env python3
"""Sum the squares of the numbers given on the command line, as a Slurm workflow.

Usage:  python3 submit_workflow.py 1 2 3 4 5 10 11

Step 1 (map):    one job array task per number runs square.py, writing
                 output/square_<i>.out
Step 2 (reduce): the results are added in groups of five by add.py, and the
                 group results are added again, recursively, until one number
                 is left.  Each add job depends on the jobs that produce its
                 inputs, so Slurm runs it only once they have all succeeded.

The final answer ends up in output/FINAL.out.
"""

import subprocess
import sys

GROUP = 5


def sbatch(*args, env=None):
    """Run sbatch and return the job ID it prints."""
    command = ["sbatch", "--parsable", *args]
    result = subprocess.run(command, capture_output=True, text=True, check=True, env=env)
    return result.stdout.strip().split(";")[0]


values = sys.argv[1:]
if not values:
    sys.exit(__doc__)

# ---- map: one array task per value ------------------------------------------
import os
env = dict(os.environ, VALUES=" ".join(values))
array_id = sbatch(f"--array=0-{len(values) - 1}", "square.sh", env=env)
print(f"map:    array job {array_id} with {len(values)} tasks")

# Each pending result is (job id to wait for, file that will hold the result)
pending = [(f"{array_id}_{i}", f"output/square_{i}.out") for i in range(len(values))]

# ---- reduce: add in groups until one result is left --------------------------
level = 0
while len(pending) > 1:
    level += 1
    groups = [pending[n:n + GROUP] for n in range(0, len(pending), GROUP)]
    pending = []
    for g, group in enumerate(groups):
        depends = "afterok:" + ":".join(job for job, _ in group)
        files = [name for _, name in group]
        outfile = f"output/add_{level}_{g}.out"
        job = sbatch(f"--dependency={depends}", f"--output={outfile}",
                     f"--job-name=add_{level}_{g}", "add.sh", *files)
        pending.append((job, outfile))
    print(f"reduce: level {level}, {len(groups)} add job(s)")

# ---- final: one more job just renames the last result ------------------------
last_job, last_file = pending[0]
final = sbatch(f"--dependency=afterok:{last_job}", "--job-name=FINAL",
               "--output=output/FINAL.out", "--partition=compute_zone2,normal",
               "--time=00:02:00", "--wrap", f"cat {last_file}")
print(f"final:  job {final} will write output/FINAL.out")
