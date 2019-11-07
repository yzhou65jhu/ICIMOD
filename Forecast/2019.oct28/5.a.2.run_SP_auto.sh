#!/bin/bash -l
#------------------------------------------------------------------------------
# NASA/GSFC,
# Computational and Information Science and Technology Office (CISTO), Code 606
#
# JHU,
# Hydroclimate Research Group (HCRG), Earth and Planetary Sciences (EPS)
#------------------------------------------------------------------------------
#
# SCRIPT:
#     run_lis.sh
#
# AUTHOR:
#     Eric M. Kemp <eric.kemp@nasa.gov>, NASA/CISTO
#     Hamada S. Badr <badr@jhu.ed>, JHU/EPS/HCRG
#
# DESCRIPTION:
#     SLURM submission script for running LIS.
#
#------------------------------------------------------------------------------
#!/bin/sh

## Specify a name for the job allocation
#SBATCH --job-name=OL_bigSA
## Specify a filename for standard output
#SBATCH --output=./logs/tryrun.log
## Specify a filename for standard error
#SBATCH --error=./logs/tryrun.err
## Set a limit on the total run time
#SBATCH --time=1:00:00
## Enter NCCS Project ID below:
#SBATCH --account s1525
## Adjust node, core, and hardware constraints
#SBATCH --ntasks=16 --constraint=hasw
# Substitute your e-mail here
#SBATCH --mail-user=yzhou65@jhu.edu
#SBATCH --mail-type=ALL


ulimit -s unlimited
sed -i "s/^\(#SBATCH --ntasks\).*/\1=140 --constraint=hasw/" 5.a.3.SearchModify_OL.sh
for i in `seq 1 4`; do #note that time ->> 3:00:00 
    jobID=$(cat JobID_OL.txt | awk '{print $NF}')
    if [ -z $jobID ]; then
        sbatch -d afterany:34846615 5.a.3.SearchModify_OL.sh > JobID_OL.txt
    else
        sbatch -d afterany:$jobID 5.a.3.SearchModify_OL.sh > JobID_OL.txt
    fi
done


