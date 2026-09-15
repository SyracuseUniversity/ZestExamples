#!/usr/bin/env python
"""A deliberately slow sum of 1 to 100 that checkpoints as it goes.

Each iteration takes one second, so the whole thing needs about 100 seconds.
Every 10 iterations the loop counter and running total are written to
checkpoint.dat.  On startup the file is loaded if it exists, so a run that
was interrupted picks up from the last checkpoint instead of starting over.

Slurm can also send a signal shortly before the job's time limit (see
checkpoint_demo.sh).  A handler catches it, writes a final checkpoint and
exits with code 99 so the batch script knows to resubmit.
"""

import signal
import sys
import time
from pathlib import Path

checkpoint = Path("checkpoint.dat")

# ---- load the checkpoint if there is one ------------------------------------
if checkpoint.is_file():
    start, total = (int(v) for v in checkpoint.read_text().split())
    start += 1
    print(f"Resuming from checkpoint: i={start - 1}, total={total}", flush=True)
else:
    start, total = 1, 0
    print("No checkpoint found, starting from the beginning", flush=True)


def save(i, total):
    # Write to a temporary file and rename it into place, so that a job killed
    # part way through the write never leaves a half-written checkpoint behind.
    tmp = checkpoint.with_suffix(".tmp")
    tmp.write_text(f"{i} {total}")
    tmp.replace(checkpoint)
    print(f"Checkpoint written at i={i}", flush=True)


# ---- write a final checkpoint if Slurm warns us the time limit is near -----
def handle_signal(signum, frame):
    print(f"Received signal {signum}, saving and exiting", flush=True)
    save(current_i, total)
    sys.exit(99)


signal.signal(signal.SIGUSR1, handle_signal)

# ---- the actual work --------------------------------------------------------
current_i = start - 1
for current_i in range(start, 101):
    total += current_i
    time.sleep(1)                      # pretend this is expensive
    if current_i % 10 == 0:
        save(current_i, total)

print(f"Finished: total = {total}", flush=True)
if checkpoint.exists():                # tidy up so the next run starts fresh
    checkpoint.unlink()
