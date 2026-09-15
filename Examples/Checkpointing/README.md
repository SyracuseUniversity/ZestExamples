# Checkpointing

It is a regrettable but unavoidable fact that sometimes computers stop working
and this is no less true of the computers that make up a Slurm cluster, such as
Zest.  Any node might stop working at any time due to a hardware or power
issue, or become disconnected due to a network issue, or it may need to be
rebooted in order to update it.  Slurm jobs also have a time limit, and a job
that reaches it is killed whether or not it has finished.

When this happens any progress since the program last saved its state is
lost.  If the job was going to run for 15 minutes and was interrupted after 10
this doesn't represent a serious problem.  However the situation is much worse
if the job was going to run for 10 days and was interrupted after 9.  Sometimes
this is called "badput" to distinguish it from "throughput" and the goal is to
minimize it.  This is where checkpointing comes in.

Broadly speaking, checkpointing is a design where a program occasionally dumps
its entire state to disk, and on startup checks to see if a saved state exists
and if so loads it.  Consider this very simple (and highly artificial!) example
of a program that adds all the numbers from 1 to 100.

```python
#!/usr/bin/env python

total = 0

for i in range(1,101):
    total += i

print(total)
```

In order to make this robust against the node going down we'll first have it
dump its state every 10 steps:

```python
#!/usr/bin/env python

total = 0

for i in range(1,101):
    total += i

    if i % 10 == 0:
        with open('checkpoint.dat','w') as checkpoint:
            checkpoint.write(f"{i} {total}")

print(total)
```

To complete the process the program needs to look for a checkpoint and load it
if there is one.

```python
#!/usr/bin/env python

from pathlib import Path

checkpoint = Path("checkpoint.dat")
if checkpoint.is_file():
    with checkpoint.open() as f_in:
        line = f_in.readline()
        start_in, total_in = line.split()
        start = int(start_in) + 1
        total = int(total_in)
else:
    start = 1
    total = 0

for i in range(start,101):
    total += i

    if i % 10 == 0:
        with open('checkpoint.dat','w') as checkpoint:
            checkpoint.write(f"{i} {total}")

print(total)
```


## How often to checkpoint

The above example demonstrates an important consideration in checkpointing, the
*granularity*.  It would be possible to dump the state after every iteration,
but then the program would be spending a lot of time opening files and writing
to them, which tend to be extremely slow operations relative to performing
computations.  A program that saves its state after every step will have no
badput, but could run 10 or 20 times slower.  On the other hand, saving too
infrequently means that if the node goes down more work will be lost.
Unfortunately there is no hard and fast rule regarding how often to checkpoint,
it comes down to deciding what the right balance is between the overhead of
checkpointing and the risk of badput for each application.


## When to checkpoint

If a program iterates over some set then a natural approach is to checkpoint
after some fraction of the iterations have been completed, as in the example.

Similarly, if a program is iterating until some condition is met then one
possible approach is to add a counter and checkpoint based on that.  For example
if there is a top-level `while` loop

```python
while not analysis_finished:
    ...
```

then checkpointing could be added as

```python
count = 0

while not analysis_finished:
    count += 1

    if count % 100 == 0:
        # do checkpointing here
```

These approaches work well if each iteration takes about the same amount of
time, checkpointing will then happen at regular intervals.  If some iterations
may take much longer than others, or more generally if losing computational time
is more of a concern than losing a number of iterations, then checkpointing can
be time based.  For example, to checkpoint every 100 seconds

```python
import time
start_time = int(time.time())

...

current_time = int(time.time())

if (current_time - start_time) > 100:
    start_time = current_time
    # Checkpoint
```

None of these solutions is inherently better or worse than the others, choosing
a method is in part a decision based on the nature of the program and in part
personal preference.


## Predicting the amount of lost work

If checkpointing is done based on number of iterations then in general there is
no way to predict how much work might be lost if the program is interrupted
before it completes.  In the very worst case the program might be removed just
before it writes the next checkpoint, in which case one complete iteration will
be lost.  This could represent ten minutes' work or several days depending on
how long each iteration takes.  This suggests that if iterations are likely to
be long or expensive that time based checkpointing might be better, but there is
no hard and fast rule.

However if a program is using time-based checkpointing then it is possible to
calculate the *expected value* of lost work, that is, on average how much work
will be lost over a large ensemble of identical programs.

For a finite set of possibilities the expected value is

```math
\sum_{\bf options\, i} i P(i)
```

where $`P(i)`$ is the probability of the option i occurring.  In the continuum
limit this becomes

```math
\int x P(x)\, dx
```

where now $`P(x)`$ is a probability density.

In the case of checkpointing, say that the program checkpoints every $`N`$
minutes and that the program may be interrupted at any time.  To determine the
probability density function it is first necessary to find the normalization
constant such that the total probability is one.  In this case the distribution
is uniform between 0 and N so we need to find C such that

```math
C \int_0^N \, dx = 1
```

This straightforwardly gives $`C = 1/N`$ (which can also immediately be seen
from the fact that for a rectangle of base $`N`$ to have an area of 1 the height
must be $`1/N`$).

The expected value is then

```math
(1/N) \int_0^N x\, dx = N/2
```

So on average $`N/2`$ minutes of work will be lost, which is what would be
expected by symmetry.


## What counts as program "state"?

As a general rule programs will need to preserve all information that they require
to resume, as in the sum example which had to save both the counter and the
total so far.  Often this will mean the value of all variables and data
structures.  When there are many of these saving them all individually may be
inconvenient, and writing them all out as strings may require additional
formatting and parsing code.

Much of this can be simplified using the Python
[Pickle](https://docs.python.org/3/library/pickle.html) library, which can dump
most Python data types to a file.  In combination with a custom class this can
greatly simplify checkpointing.


```python
#!/usr/bin/env python

import pickle
from pathlib import Path

class State:
    def __init__(self):
        self.counter = 0
        self.total   = 0

        # Other state variables...

checkpoint = Path("checkpoint")
if checkpoint.is_file():
    with checkpoint.open('rb') as f_in:
        state = pickle.load(f_in)
else:
    state = State()

# start doing work...
# ...
# Save a new checkpoint

checkpoint = Path("checkpoint")
with checkpoint.open('wb') as f_out:
    pickle.dump(state, f_out)
```

One more practical point: write the new checkpoint to a temporary name and
rename it into place once it is complete.  Otherwise a job killed in the middle
of writing leaves behind a half-written checkpoint that the next run will
choke on.  Renaming a file is atomic on Zest's home filesystem.

```python
tmp = checkpoint.with_suffix('.tmp')
with tmp.open('wb') as f_out:
    pickle.dump(state, f_out)
tmp.replace(checkpoint)
```


## Additional considerations for multi-threaded applications

Using multiple threads or processes can greatly speed up programs by
distributing the work over multiple CPUs, and the Python
[Multiprocessing](https://docs.python.org/3/library/multiprocessing.html) and
[Threading](https://docs.python.org/3/library/threading.html) libraries make it
easy to utilize this kind of parallelism.  However, some care must be taken to
ensure that checkpoints are *consistent*, meaning they must represent a program
state that "makes sense" in the context of what the program is doing.  If one
thread is creating a checkpoint while another thread is changing data that is
being written then the resulting checkpoint may be broken.  Returning to the sum
example, it's conceivable that the checkpoint might save the state while `i=20`
but `total` has already been modified to include terms up to `i=25`.

This is an example of a much more general problem of keeping shared data
consistent across multiple threads, which in general can be very difficult and
is beyond the scope of this document.  For now just note that this is something
to be aware of.


## Slurm specifics

Slurm itself does not checkpoint user processes, but it provides three things
that make checkpointing programs easy to run.

**A warning before the time limit.**  Adding

```bash
#SBATCH --signal=B:USR1@60
```

to a batch script asks Slurm to send the `USR1` signal to the batch script
60 seconds before the job's time limit.  A program can catch this signal,
write a final checkpoint and exit cleanly rather than being killed mid-step.
The `B:` means the signal goes to the batch shell rather than directly to the
program, so the script has to pass it on, see the example below.

**Requeueing.**  A job submitted with

```bash
#SBATCH --requeue
```

is put back in the queue if its node fails, and the script can also ask for
this itself with `scontrol requeue $SLURM_JOB_ID`.  When the job runs again it
starts from the beginning of the batch script, in the same directory, so it
will find the checkpoint file and resume.

**Dependencies.**  For very long runs an alternative is a chain of shorter
jobs, each submitted with `--dependency=afterany:<previous job>` so that it
starts when the previous one ends and continues from the checkpoint.  Shorter
jobs are also easier for Slurm to schedule.  See
[Parallelism](../Parallelism) for more on dependencies.

Also keep checkpoint files on the home filesystem, which is shared by all
nodes, rather than in `/tmp` on the node, which is not.

### Trying it out

This directory contains a runnable version of the sum example.
`checkpoint_demo.py` takes a second per iteration (so about 100 seconds in
total), checkpoints every 10 iterations, and catches `USR1` to write a final
checkpoint and exit with code 99.  The batch script `checkpoint_demo.sh`
deliberately gives it only one minute

```bash
#SBATCH --time=00:01:00
#SBATCH --signal=B:USR1@20
#SBATCH --requeue

trap 'kill -USR1 $PID' USR1

python3 checkpoint_demo.py &
PID=$!
wait $PID
STATUS=$?
while kill -0 $PID 2>/dev/null; do    # wait is interrupted by the trap, so wait again
    wait $PID
    STATUS=$?
done

if [ $STATUS -eq 99 ]; then
    scontrol requeue $SLURM_JOB_ID
fi
```

The program has to be started in the background and waited for, rather than
run directly, because bash only runs a trap once the foreground command has
finished, which would be too late.  Slurm may deliver the signal up to a
minute earlier than requested, so leave a comfortable margin.

Submit it with

```bash
sbatch checkpoint_demo.sh
```

Watch `squeue --me`, after about 40 seconds the job will receive the signal,
save, and go back to the pending state, then run a second time and finish.
A requeued job keeps its job ID, so it writes to the same output file,
`output/checkpoint_demo_<jobid>.out`.  By default Slurm truncates that file
when the job starts again, the script adds `--open-mode=append` so that both
runs are visible.  The output looks like

```
No checkpoint found, starting from the beginning
Checkpoint written at i=10
Checkpoint written at i=20
Checkpoint written at i=30
Received signal 10, saving and exiting
Checkpoint written at i=39
Not finished, requeueing job 3127710
Resuming from checkpoint: i=39, total=780
Checkpoint written at i=40
...
```


## Checkpointing in large applications

So far this document has focused on modifying code developed at SU, however
Zest is also used to run large, sophisticated open source programs
developed elsewhere.  In general applications that are meant to be run on a
cluster will be able to do some form of checkpointing, this should appear in the
application's documentation.  As two examples:

  * [Checkpointing in GROMACS](https://manual.gromacs.org/current/user-guide/managing-simulations.html)
    using `.cpt` files with `-cpi`, `-cpo` and `-maxh`.  See the
    [GROMACS working example](GROMACS.md).
  * [Checkpointing in LAMMPS](https://docs.lammps.org/restart.html) with the
    `restart` command.  See the [LAMMPS working example](LAMMPS.md).


## The best way to do checkpointing...

... is not to need it!  Recall that this discussion started with the observation
that checkpointing probably isn't needed if a program is only going to run for
15 minutes or so.  If a program is going to run for 10 hours it is better, when
possible, to split it into 60 programs that each run for 10 minutes.  Not only
does this eliminate the need for checkpointing, but obviously the total time to
run is much less.  See the document on [parallelization strategies](../Parallelism)
for some techniques and strategies.

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
