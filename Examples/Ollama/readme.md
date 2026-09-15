# Llama/Ollama

This is a simple example of running a basic LLM under Slurm with Singularity.  This
demonstrates a non-interactive use, a single prompt is given which generates a response,
the process then exits.  If your research requires interactive use of an LLM please contact
researchcomputing@syr.edu and we'll be happy to discuss the options.


## Installing Ollama

For most users the easiest option will be to use a
[Singularity](../Singularity)
container.  It's worth reading through that document to better understand
what containers are and how they work, but in summary a container encapsulates
an entire working environment into a single file.  There's a large library of
containers available for Docker containers on
[Dockerhub](https://hub.docker.com/), and while we don't support Docker
directly the containers are largely compatible.

To download the Ollama container the command is

```bash
singularity pull docker://ollama/ollama:0.6.8
```

This command will only need to be run once.  It produces `ollama_0.6.8.sif`
in the current directory.

Note the version number.  Zest's GPU nodes currently have NVIDIA driver 545
(CUDA 12.3) and newer Ollama releases do not work with it: the current
`ollama/ollama` image logs `NVIDIA driver too old ... required_driver="550
or newer"` and runs on the CPU, and the 0.11 series reports the GPU as found
but its CUDA runner still silently loads the model into CPU memory.  In both
cases a one-line answer from a small model takes several minutes instead of
a few seconds, because the CPU fallback also starts far more threads than
the job has cores.  Version 0.6.8 is the most recent release we have
verified to genuinely run on the GPU on Zest (look for `CUDA0 model buffer`
in the server log).  Once the drivers are updated this restriction will go
away and the plain `docker://ollama/ollama` image can be used.

## Running the sample program

This directory contains a batch script `ollama_app.sh` which starts an ollama
server and then runs a single query "What is Slurm, in two sentences?" taken from
`input/prompt.txt` against the small `llama3.2:1b` model.  The first time the
job runs it will download the model, which is about 1.3 GB and is kept in
`~/.ollama/models` so that later jobs can reuse it.  To submit this to the
cluster the command is

```bash
sbatch ollama_app.sh
```

After submitting you can check on the progress with

```bash
squeue --me
```

or monitor it with

```bash
watch -n 5 squeue --me
```

When it completes you can check the output with

```bash
cat output/ollama_app.out
```

The server's own log is in `output/serve.out`, it is the place to look if the
answer is missing, and it also confirms that the GPU was really used: look
for `inference compute` with `library=cuda` and `name="NVIDIA A40"`, and
further down `CUDA0 model buffer size` when the model is loaded.  The whole
job should take well under a minute once the model has been downloaded.

## Notes

  * The batch script requests a GPU from the `gpu_zone2` or `gpu` partitions
    with `--gres=gpu:1`, and `singularity exec --nv` passes that GPU into the
    container.  Ollama will fall back to the CPU if no GPU is present, but
    slowly.
  * Larger models need more GPU memory.  Zest's GPUs are NVIDIA A40s with
    46 GB, which is enough for most models up to about 30 billion parameters
    at the default quantization.  Models are listed at
    [ollama.com/library](https://ollama.com/library).
  * To run many prompts, put one per file and use a [job array](../multipleJobs)
    rather than one very long job.

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
