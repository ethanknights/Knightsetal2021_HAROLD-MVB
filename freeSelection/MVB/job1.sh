#!/bin/bash
#SBATCH -J job1
#SBATCH -o job1.out

/hpc-software/matlab/r2019a/bin/matlab -nodesktop -nosplash \
cd /imaging/henson/users/ek03/projects/HAROLD/freeSelection/MVB -r wrapper
