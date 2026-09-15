# JAX

[JAX](https://docs.jax.dev/en/latest/) is a Python library providing optimized
mathematical operations for both CPUs and GPUs.  Of particular note, it provides
"just in time compilation" of math routines, enabling dynamic optimization
beyond the static optimizations in other numeric libraries such as numpy.
Specifically, this approach allows for a couple of very powerful optimizations:

  * The compiler knows the exact size of the arrays being operated on, this
    eliminates the need for size checks and allows code to be more specific.
  * Several operations can be chained together.  Moving data between main memory
    and GPU memory is very slow and can often be a performance bottleneck.  JAX
    can optimize code such that data stays on the GPU between operations, rather
    than needing to be moved back and forth.

In addition JAX provides sophisticated memory management tools for moving data
between host memory and GPU memory, as well as tools to distribute computation
across multiple devices.

## Installing JAX

JAX is a standard Python library and can be installed using pip.  Assuming
Conda has been installed as in the [Python](../python) example, the first
step is to create a new environment with pip in it:


```bash
eval "$(${HOME}/miniconda3/bin/conda shell.bash hook)"
conda create -y -n jax python=3.12 pip numpy
conda activate jax
```

then use pip to install JAX.  Zest's GPU nodes run NVIDIA driver 545, which
supports CUDA 12, so install the CUDA 12 build, which brings the CUDA
libraries with it as Python packages

```bash
pip install -U "jax[cuda12]"
```

If a feature you need is only in the CUDA 13 build, `pip install -U
"jax[cuda13]"` works too but requires the [CUDA 13 compatibility
library](../CUDA13).

## Using JAX

As a first example consider the problem of multiplying two matrices and then
finding the eigenvalues of the result.  With numpy this would be done as:

```python
#!/usr/bin/env python

import numpy as np
import time

def mult_and_eigen(A,B):
    C = np.matmul(A,B)
    return np.linalg.eig(C)

start_time = time.time()

for _ in range(1000):
    A = np.random.random((100, 100))
    B = np.random.random((100, 100))

    Z = mult_and_eigen(A,B)[0]

end_time   = time.time()

print(end_time - start_time)
```

To use JAX it is only necessary to import the library and change some of the
numpy calls to use it

```python
import jax.numpy as jnp

def mult_and_eigen(A,B):
    C = jnp.matmul(A,B)
    return jnp.linalg.eig(C)
```

This illustrates an important feature of JAX, it can largely be used as a
drop-in replacement for numpy.

The final step is to enable compilation

```python
compiled = jax.jit(mult_and_eigen)

start_time = time.time()

for i in range(1000):
    A = np.random.random((100, 100))
    B = np.random.random((100, 100))

    Z = compiled(A,B)[0]
```

The file `jax_demo.py` in this directory runs all three versions and prints
the time each one takes.  To run it on a GPU

```bash
sbatch jax_demo.sh
```

and when it finishes look at `output/jax_demo.out`.  The first line lists the
devices JAX found, on a GPU node it should show `CudaDevice(id=0)`.


## What's going on

Against expectations JAX on a GPU performs much worse than numpy on a CPU for
this example.  However this is a consequence of the artificial nature of the
example, the matrices are tiny, the eigenvalue routine is not one that
benefits from a GPU, and new random matrices are moved to the GPU on every
iteration.  As noted in the [JAX
FAQ](https://docs.jax.dev/en/latest/faq.html#is-jax-faster-than-numpy)


> Keeping all that in mind, in summary: if you're doing microbenchmarks of
> individual array operations on CPU, you can generally expect NumPy to
> outperform JAX due to its lower per-operation dispatch overhead. If you're
> running your code on GPU or TPU, or are benchmarking more complicated
> JIT-compiled sequences of operations on CPU, you can generally expect JAX to
> outperform NumPy.

As code complexity grows JAX's advantages will become more apparent.  As always,
see the project's own [documentation](https://docs.jax.dev/en/latest/index.html)
for more advanced use.


## Memory management

JAX allows data structures to be distributed across multiple devices, this allows
structures to be transparently larger than could fit on a single GPU, while still
often getting performance boosts from that portion that can be stored on the
device.  Full details are in the [host
offloading](https://docs.jax.dev/en/latest/notebooks/host-offloading.html)
section of the manual but here are some examples to get a taste of how it works.

First, consider a situation where there are two GPUs available (on Zest
this would be done by changing the batch script to `#SBATCH --gres=gpu:2`).  This code
will create a *Mesh* named `x` containing both devices.

```python
from jax.sharding import Mesh, PartitionSpec as P, NamedSharding
import jax.numpy as jnp
import jax

devices = jax.local_devices()[:2]
x_mesh  = Mesh(devices, ('x',))
```

The next step is to tell JAX how to split data across the two devices by
specifying the *sharding*.  Here the data will be split along the first axis

```python
sharding = NamedSharding(x_mesh, P('x', None))
```

Next, create some data in a standard host memory array, and use `device_put` to
move it to the GPUs

```python
cpu_array  = jnp.arange(8, dtype=jnp.float32)
gpus_array = jax.device_put(cpu_array, sharding)
```

This will put the portion of the array containing `[0,1,2,3]` on device 1 and
`[4,5,6,7]` on device 2, but all subsequent operations on this array will work
as if it were all on one device, up to issues of performance.

It is also possible to distribute data between host and GPU memory.  First find
the local CPU and GPU in the list of devices, and construct an array containing
them

```python
cpu_device = [d for d in jax.devices() if d.platform == 'cpu'][0]
gpu_device = [d for d in jax.devices() if d.platform == 'gpu'][0]
devices    = jnp.array([cpu_device, gpu_device])
```

The rest of the code is unchanged and, again, all operations on this data will
work without the programmer needing to keep track of the underlying storage.

## Distributed computing

The previous section hints at the power of sharding over a mesh of devices, but
JAX can go further and work across devices distributed across different nodes.
The details are beyond the scope of this tutorial, please see the official
documentation for
[Introduction to multi-controller JAX](https://docs.jax.dev/en/latest/multi_process.html)
and a more complete example in
[The Training Cookbook](https://docs.jax.dev/en/latest/the-training-cookbook.html).
On Zest a multi-node JAX job is started with `srun` in the same way as the
[MPI](../MPI) example, with `--gres=gpu:4` to take all the GPUs on each node.


---
Please email any questions or comments about this document to Research Computing at [researchcomputing@syr.edu](mailto:researchcomputing@syr.edu).
