# Julia

This is a simple example of running a basic Julia program under Slurm. This example uses a
single CPU and can serve as a template for Julia programs that may require additional packages.
For GPU examples using Julia, the setup is similar but requires adding CUDA.jl to your environment
and requesting a GPU as in the [GPU](../GPU) example.

**Note:** Julia uses just-in-time (JIT) compilation, so the first run of any script will be
slower while packages are compiled. For this simple demo, expect a minute or two of startup time.
For long-running research jobs this overhead is negligible, but it can be surprising for
short scripts. See the Julia-specific considerations section below for more details.


## Installing Conda

For most Julia users we recommend installing Julia through [Miniforge](https://github.com/conda-forge/miniforge)
and using Conda to manage your environment.

Download and run the installer:

```bash
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh -b -p $HOME/miniconda3
```

Then initialize Conda:

```bash
~/miniconda3/bin/conda init
```

After running `conda init`, log out and log back in for the changes to take effect.


## Installing Julia and additional packages

Once Conda is set up, create an environment with Julia:

```bash
conda create -y -n julia conda-forge::julia
conda activate julia
```

Julia has its own package manager for Julia-specific packages. To add packages
from the command line:

```bash
julia -e 'using Pkg; Pkg.add(["LinearAlgebra", "Statistics"])'

# For GPU support, you would add the CUDA package:

julia -e 'using Pkg; Pkg.add("CUDA")'
```


## Running the sample program

This directory contains a sample program `julia_demo.jl` which performs some
basic array operations and prints the results. To submit this to the cluster:

```bash
sbatch julia_demo.sh
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
cat output/julia_demo.out
```


## The batch script

Note that `julia_demo.sh` does not simply call `julia julia_demo.jl`. Batch jobs
start in a fresh shell where Conda has not been set up, so the script first
enables the `conda` command and activates the environment before running the
Julia code. For most simple Julia applications you should be able to modify
the final line without changing anything else.


## Julia-specific considerations

Julia uses just-in-time (JIT) compilation, so the first run of any script is slower
while packages are compiled. For long-running batch jobs this overhead is negligible.
Subsequent runs are faster because Julia's package cache in `~/.julia` is on the
shared home filesystem and is therefore available to every node.

Julia can use multiple threads with `julia --threads $SLURM_CPUS_PER_TASK`, in
which case also raise `--cpus-per-task` in the batch script to match.

## What to read next

There are also documents on how to [parallelize](../Parallelism) code to make optimal use of the cluster
and how to use specialized [file formats](../FileManagement) to optimize data storage and access.

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
