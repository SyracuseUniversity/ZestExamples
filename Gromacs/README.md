# GPU - SLURM GPU Job Example  
This example demonstrates running a **very small** GROMACS job on Zest’s GPU partitions.  

The simulation is a tiny water box, pre-built into `small_test.tpr` so no setup steps are required.  
# File  
- `gromacs_example.sh` – SLURM batch script for submitting the job.  
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
- md.log
# Sample TPR Methodology  
You can generate or provide your own `.tpr` file for testing.  

The `.tpr` file included in this repository was generated once and stored here so that it can be run without preparing inputs each time.  

Below are the steps and parameters used to create it.   

1 - Create a minimal MDP file ('minim.mdp')
```
integrator  = steep
emtol       = 1000.0
emstep      = 0.01
nsteps      = 500
nstlist     = 1
cutoff-scheme = Verlet
coulombtype = PME
rcoulomb    = 1.0
rvdw        = 1.0
pbc         = xyz
```  
2 - Create a small water box  
```
module load gromacs
gmx solvate -cs spc216.gro -o water_box.gro -box 3 3 3
```
3 - Generate topology  
```
gmx pdb2gmx -f water_box.gro -o processed.gro -p topol.top -water spce
# When prompted, enter '14' for Gromos54a7
```
4 - Generate the .tpr file  
```
gmx grompp -f minim.mdp -c processed.gro -p topol.top -o small_test.tpr -maxwarn 1
```
Once generated, small_test.tpr can be submitted with the provided SLURM script to run a short GPU test job.  
# Additional Resources  
You can find additional Zest information [in Answers](https://answers.atlassian.syr.edu/wiki/x/YAfJCQ).  
For Gromacs assistance, see [the official Gromacs documentation](https://www.gromacs.org/).  
As always, questions can be directed to researchcomputing@syr.edu. 
