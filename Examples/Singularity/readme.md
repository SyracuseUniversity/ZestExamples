# Singularity

In most cases any software that would be needed on Zest can be installed
directly in users' home directories through tools like [Conda](../python) or
[uv](../uv).  However, sometimes software needs libraries that can only be installed
through system management tools like `dnf` or `apt`.  In such cases
effectively what is needed is an entire computer that the user has complete control over,
a requirement which appears to be fundamentally at odds with the cluster as a shared
resource.

This is where *containers* come in.  Containers are a technology that allow an
entire working environment to be packed into a single file, "going into" a
container is effectively like ssh-ing into another computer, with its own set of
software.  A container can even have a different operating system than the
computer where the container is installed, an Ubuntu container can run on
Zest's AlmaLinux nodes.

In addition to the flexibility, containers can be a very convenient way to install
large, complex programs even when other installation options are available.

Possibly the best known container system is [Docker](https://www.docker.com/),
which is not available on Zest.  However,
[Singularity](https://docs.sylabs.io/guides/3.7/user-guide/) is an alternate technology
that is available, and is largely compatible with Docker.  Zest provides
Singularity 3.7 through a module that is loaded automatically at login and in
batch jobs

```bash
$ singularity --version
singularity version 3.7.1-5.1.ohpc.2.1
```

If you have used [Apptainer](https://apptainer.org/) elsewhere (for example
on OrangeGrid), note that Apptainer is the successor project to Singularity and
the commands are the same, just replace `apptainer` with `singularity`.

## Getting a container

Singularity containers can be built from scratch, however this requires system privileges
that users don't have.  If you think you need a custom container, please email
[researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).  In many cases however
a suitable Docker container will already exist and can be imported.

As an example, here's how to download a container with the
[Haskell](https://www.haskell.org/) programming language

```bash
singularity pull docker://haskell
```

This converts the Docker image into a single file, `haskell_latest.sif`.  The
conversion is done on the login node and can take several minutes for a large
image, it also uses a few gigabytes of temporary space.  If it fails with
"no space left on device" point the temporary and cache directories at your
home directory first

```bash
export SINGULARITY_TMPDIR=$HOME/singularity_tmp
export SINGULARITY_CACHEDIR=$HOME/singularity_cache
mkdir -p $SINGULARITY_TMPDIR $SINGULARITY_CACHEDIR
```

After pulling it, verify that the Haskell compiler is not available on the host
system

```
$ ghc
-bash: ghc: command not found
```

Then go into the container with

```bash
singularity shell haskell_latest.sif
```

The prompt will change and ghc will be available

```bash
$ singularity shell haskell_latest.sif
Singularity> ghc
ghc-9.14.1: no input files
```

It's also possible to run a command that exists inside the container from outside it

```bash
$ singularity exec haskell_latest.sif ghc
ghc-9.14.1: no input files
```

Your home directory is automatically visible inside the container, so
programs in the container can read and write your files as usual.


## Using Singularity on Zest

The `exec` command form is the key to using Singularity on the cluster, since it
can be embedded directly into a batch script.  The example in this directory
uses ghc to compile the [Sieve of
Eratosthenes](https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes), a method of
finding prime numbers.  A version of the algorithm can be expressed very
elegantly in Haskell as

```haskell
sieve (x:xs) = x:(sieve $ filter (\a -> a `mod` x /= 0) xs)
ans = takeWhile (<200) (sieve [2..])
```

For details on what this is doing, and how to make it more efficient,
see [this paper](https://www.cs.hmc.edu/~oneill/papers/Sieve-JFP.pdf).

To try the example, first pull the container as above so that
`haskell_latest.sif` is in this directory, then run

```bash
sbatch sieve_demo.sh
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
cat output/sieve_demo.out
```

## Using GPUs from a container

Add the `--nv` flag to `singularity exec` and the NVIDIA driver and GPU
devices from the host are made available inside the container, this is
combined with a `#SBATCH --gres=gpu:1` request in the batch script.  The
[Ollama](../Ollama) example shows this in action.

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
