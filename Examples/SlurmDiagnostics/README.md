# Slurm Diagnostics

This directory contains programs and recipes that are useful for getting a picture of the cluster
and of your own jobs.


## freeResources

A basic Python program (no extra packages needed) that ingests information from `scontrol` and
summarizes the number of free CPUs, memory and GPUs in each partition, along with the largest
block of free CPUs on a single node.  It can be run directly

```bash
python3 freeResources.py

Partition          CPUs free/total    Memory (GB) free/total   GPUs free/total
compute_zone2        984/8400             8786/23618                         -
gpu                  256/768              2496/2869                      17/24
gpu_zone2           1376/1920             6253/7129                      14/60
longjobs              24/2240             2193/6625                          -
normal              2854/7424            16169/25621                         -

Largest free block of CPUs in gpu: 128 on node1226 (128 CPUs)
Largest free block of CPUs in gpu_zone2: 128 on node1226 (128 CPUs)
```

(GPU nodes appear in both GPU partitions, which is why the same node can be
listed twice.)

or restricted to particular partitions

```bash
python3 freeResources.py --partition gpu,gpu_zone2
```

It can also read the `scontrol` output from a pipe, which makes it easy to
save a snapshot and analyze it later

```bash
scontrol show node --oneliner | python3 freeResources.py -
```

Nodes that are down or drained are not counted.  This is a good way to decide
which partition to submit to, or how many CPUs to ask for so that a job starts
promptly.


## Other recipes

This is a collection of Slurm commands that don't require any additional programs.

Summary of partitions and node states

```bash
sinfo
```

Every node with its CPUs, memory, GPUs and current state

```bash
sinfo -N -o "%N %P %c %m %G %T"
```

Your jobs, with the reason any pending ones are waiting

```bash
squeue --me -o "%.10i %.12P %.20j %.2t %.10M %.6D %R"
```

Everything you ran in the last week, and whether it succeeded

```bash
sacct -X -S now-7days --format=jobid,jobname%20,partition,state,exitcode,elapsed,nodelist
```

How much CPU and memory a finished job actually used, compared to what it asked for

```bash
seff <jobid>
```

Peak memory of every step of a job, useful for setting `--mem`

```bash
sacct -j <jobid> --format=jobid,maxrss,reqmem,elapsed
```

Details of a pending or running job, including why it is waiting

```bash
scontrol show job <jobid>
```

Which GPUs are in use, and by whom

```bash
squeue -p gpu,gpu_zone2 -t RUNNING -o "%.10i %.12u %.12P %.6D %.10M %b"
```

Jobs waiting for a GPU and for how long

```bash
squeue -p gpu,gpu_zone2 -t PENDING -o "%.10i %.12u %.10V %R"
```

Estimated start time of your pending jobs

```bash
squeue --me --start
```

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
