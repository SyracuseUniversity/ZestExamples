# GPU - SLURM GPU Job Example  
This example demonstrates running a **very small** GROMACS job on Zest’s GPU partitions.  
The simulation is a tiny water box, pre-built into `small_test.tpr` so no setup steps are required.  
# File  
- `gromacs_hello.sh` – SLURM batch script for submitting the job.  
- `small_test.tpr` – Pre-generated GROMACS run file (tiny water box).  
# Running the Sample Job  
Once you have the [submission file]() in your home directory, you can edit it as needed and submit with the following:  
```
sbatch gromacs_example.sh
```
# Reviewing the Output  
To review the output, you can locate the output files in the working directory.  
You're output should look similar to the output found in the corresponding files:  
- confout.gro  
- ener.edr  
- traj.trr  
-md.log  
# Additional Resources  
You can find additional Zest information [in Answers](https://answers.atlassian.syr.edu/wiki/x/YAfJCQ).  
For Gromacs assistance, see [the official Gromacs documentation](https://www.gromacs.org/). 
As always, questions can be directed to researchcomputing@syr.edu. 
