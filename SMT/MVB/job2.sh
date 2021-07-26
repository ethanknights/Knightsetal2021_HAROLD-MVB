#!/bin/bash
#SBATCH -J job2
#SBATCH -o job2.out
#SBATCH --mem-per-cpu 3G
#SBATCH --time 24:00:00

/hpc-software/matlab/r2019a/bin/matlab cd /imaging/henson/users/ek03/projects/HAROLD/SMT/MVB -r wrapper