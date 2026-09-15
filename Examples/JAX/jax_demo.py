#!/usr/bin/env python
"""Compare numpy, JAX and JIT-compiled JAX on the same small problem.

Multiplies two random 100x100 matrices and finds the eigenvalues of the
result, 1000 times, and reports the time for each approach.
"""

import time

import numpy as np
import jax
import jax.numpy as jnp

print("JAX devices:", jax.devices())


def numpy_mult_and_eigen(A, B):
    C = np.matmul(A, B)
    return np.linalg.eig(C)


def jax_mult_and_eigen(A, B):
    C = jnp.matmul(A, B)
    return jnp.linalg.eig(C)


compiled = jax.jit(jax_mult_and_eigen)


def timeit(label, function):
    start_time = time.time()
    for _ in range(1000):
        A = np.random.random((100, 100))
        B = np.random.random((100, 100))
        Z = function(A, B)[0]
        if hasattr(Z, "block_until_ready"):
            Z.block_until_ready()
    print(f"{label:<12} {time.time() - start_time:6.2f} seconds")


timeit("numpy", numpy_mult_and_eigen)
timeit("jax", jax_mult_and_eigen)
timeit("jax.jit", compiled)
