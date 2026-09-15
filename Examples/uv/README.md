# uv

[uv](https://github.com/astral-sh/uv) is a relatively new package manager for
Python that offers a number of advantages over systems like `pip` and `conda`.
There are lots of good tutorials available online, such as [this
one](https://realpython.com/python-uv/) from Real Python, but the notes here
should be enough to get started using uv on Zest.


## Installation

To install uv run the following command:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Note that in general it is a security risk to download and run scripts off the
internet, this is also the case when installing Conda.  uv itself is
trustworthy, however there is always the risk that the site hosting it has been
compromised and is serving malware instead of the real program.  If preferred
the script can be downloaded and inspected before running

```bash
curl -LsSf https://astral.sh/uv/install.sh > install.sh
less install.sh
sh install.sh
```

The installer puts `uv` in `~/.local/bin` and adds that directory to your
`PATH` the next time you log in.

## Creating a project

For a long time now Python has encouraged developing large projects in their
own environments.  Doing so makes it easier to keep track of the exact version
of libraries that each project depends on, and to ensure that projects that
require different or conflicting versions don't interfere with each other.

In "vanilla" python environments are managed with venv and pip

```bash
python -m venv example
source example/bin/activate
pip install numpy
```

Conda offers its own mechanism
```bash
conda create --name example
conda activate example
conda install numpy
```

uv simplifies this process.  To create a new environment

```bash
uv init example
```

After doing this there will be a new directory named `example`.  There is no
need to activate the environment, just `cd example` and as long as you are in
this directory (or a subdirectory) you'll be in the `example` environment.

uv also sets up some initial files

```bash
$ cd example
$ ls

main.py  pyproject.toml  README.md
```

`README.md` is initially empty, it's created on the assumption that the project
will be checked into github, codeberg, or other web-based git repository which
will show `README.md` as the front page (like the file you're reading right
now!)  Creating a git repository for your project is always a good idea, it
helps protect from accidentally deleting files and makes it easier to
collaborate on code or share it with others.  The process is beyond the scope
of this document however.

`main.py` is a very small stub, it's a convenient starting point but probably
won't be used much in practice.

`pyproject.toml` is a [TOML](https://toml.io/en/) file that holds all the
information about the environment.  Like the `requirements.txt` file that pip
uses, this file is sufficient for anyone else to recreate the exact environment
that you're using, including the version of Python, the libraries in use, and
their versions.  See the full uv documentation for details, this page will only
note a few features.


## Adding new packages

This couldn't be simpler.  To add numpy to the environment

```bash
$ uv add numpy
```

Note that after doing so `pyproject.toml` has changed to include

```toml
dependencies = [
    "numpy>=2.3.4",
]
```

If a specific version were required it could be specified as well

```bash
uv add "numpy==2.3.4"
```

Rather than using `uv add` to add packages it's also possible to edit the toml
file and then ask uv to update the environment.  Edit `pyproject.toml` and
change the `dependencies` entry to

```toml
dependencies = [
    "numpy>=2.3.4",
    "scipy==1.16.2",
]
```

then lock this configuration

```bash
$ uv lock
Resolved 3 packages in 152ms
Added scipy v1.16.2
```

and finally sync the environment with the changes

```bash
$ uv sync
Resolved 3 packages in 2ms
Prepared 1 package in 3.70s
Installed 1 package in 2.89s
 + scipy==1.16.2
```

Scipy is now available.

Next let's consider something more complex, [PyTorch](https://pytorch.org/).  The
obvious thing to try is

```bash
$ uv add pytorch
```

This doesn't work, but uv provides a very helpful error message

```
Exception: You tried to install "pytorch". The package named for PyTorch is "torch"
```

With that change it works

```bash
$ uv add torch numpy
```

Note that a lot of other packages are brought in automatically, in particular the
NVidia libraries.  This is a significant improvement over Conda, where it was often
necessary to manually add the CUDA libraries.  (numpy is added at the same
time because PyTorch complains if it is missing.)

There is one Zest-specific wrinkle.  The default `torch` package is currently
built for CUDA 13, which needs a newer NVIDIA driver than Zest's GPU nodes
have (driver 545, CUDA 12.3), so it would silently run on the CPU.  PyTorch
publishes builds for older CUDA versions on its own package index, and uv
can be told to take `torch` from there.  Add the following to the end of
`pyproject.toml`

```toml
[[tool.uv.index]]
name = "pytorch-cu126"
url = "https://download.pytorch.org/whl/cu126"
explicit = true

[tool.uv.sources]
torch = { index = "pytorch-cu126" }
```

then rebuild the environment

```bash
uv sync
```

`uv pip list | grep torch` should now show a version ending in `+cu126`.
This is the same recipe as in the [uv
documentation](https://docs.astral.sh/uv/guides/integration/pytorch/), which
also shows how to do the same for `torchvision` and `torchaudio`.


## Running under Slurm

This directory includes an `example.py` file which uses PyTorch to do some simple
tensor calculations.  To run it, first copy it into the `example` directory.  One quirk
of uv is that rather than calling Python directly uv manages running programs

```bash
$ uv run example.py

Using CPU
[...]
Result: y = 0.012357489205896854 + 0.8317000865936279 x + -0.002131874905899167 x^2 + -0.08976855874061584 x^3
```

Next, to run under Slurm a batch script is needed.  Unlike Conda (see the
[python](../python) example) it is *not* necessary to set up the environment
in the batch script, uv handles everything.  The one catch is that
`~/.local/bin` may not be on the `PATH` when a batch job starts, so
`example.sh` gives the full path to uv:

```bash
${HOME}/.local/bin/uv run example.py
```

Copy `example.sh` to the example directory as well and run

```bash
sbatch example.sh
```

Shortly after, depending on how busy the cluster is, `example.out` should include

```
Using GPU
1
[...]
Result: y = 0.03427441045641899 + 0.828214168548584 x + -0.005912904627621174 x^2 + -0.08927271515130997 x^3
```

The batch script asks for the GPU with

```
#SBATCH --partition=gpu_zone2,gpu
#SBATCH --gres=gpu:1
```

see the [PyTorch](../PyTorch) example for more on these lines.  If the
output says `Using CPU` and `example.err` contains "The NVIDIA driver on
your system is too old", the CUDA 13 build of torch was installed, go back
and add the `pytorch-cu126` index described above.

---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
