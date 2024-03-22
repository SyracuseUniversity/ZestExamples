#!/usr/bin/env python
from mpi4py import MPI


# Modified example from
# https://cloudmesh.github.io/cloudmesh-mpi/report-mpi.pdf

def ring(count):
    comm = MPI.COMM_WORLD # Communicator
    rank = comm.Get_rank() # Get the rank of the current process
    size = comm.Get_size() # Get the size of the communicator group

    if rank == 0:
        print(f'Communicator group with {size} processes')
        data = 0 

    for i in range(0, count):
        if rank == 0:
            data += 1
            comm.send(data, dest=rank + 1) # send data to neighbor
            data = comm.recv(source=size - 1)
            print(f'Final data received in process 0: {data}')
        elif rank == size - 1:
            data = comm.recv(source=rank - 1) # recieve data from neighbor
            data += 1 # Data is modified
            comm.send(data, dest=0) # Sent to process 0, closing the ring
        elif 0 < rank < size -1:
            data = comm.recv(source=rank - 1) # recieve data from neighbor
            data += 1 # Data is modified
            comm.send(data, dest=rank + 1) # send to neighbor

    if rank == 0:
        print(f'Final data received in process 0: {data}')
        assert data == count * size # verify
        print("Completed sucessfully")

if __name__ == '__main__':
    ring(8)

