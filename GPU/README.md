# GPU - SLURM GPU Job Example

This example demonstrates how to submit a very simple job to the **GPU partitions**, gpu and gpu_zone2, on the Zest cluster using SLURM.  
It requests a single GPU, prints basic job information, displays GPU details with `nvidia-smi`, and reports the CUDA compiler version.  
Note that you can request up to four (4) GPUs in Zest if your code/scripts can utilize them.  
# Running the Sample Job  
Once you have the [submission file]() in your home directory, you can edit it as needed and submit with the following:  
```
sbatch hello_gpu.sh
```
# Reviewing the Output  
To review the output, you can locate the output file in the working directory.  
You're output should look similar to the output found on the [example output page]()  
# Additional Resources  
You can find additional Zest information [in Answers](https://answers.atlassian.syr.edu/wiki/x/YAfJCQ).  
As always, questions can be directed to researchcomputing@syr.edu. 
