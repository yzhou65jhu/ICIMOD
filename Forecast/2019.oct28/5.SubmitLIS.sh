#!/bin/sh

## Specify a name for the job allocation
#SBATCH --job-name=Submit
## Specify a filename for standard output
#SBATCH --output=./logs/tryrun.log
## Specify a filename for standard error
#SBATCH --error=./logs/tryrun.err
## Set a limit on the total run time
#SBATCH --time=1:00:00
## Enter NCCS Project ID below:
#SBATCH --account s1525
## Adjust node, core, and hardware constraints
#SBATCH --nodes=1
# Substitute your e-mail here
#SBATCH --mail-user=yzhou65@jhu.edu
#SBATCH --mail-type=ALL


export LISRUN=/discover/nobackup/projects/grace/Yifan/LISRUN/SALDAS/Forecast/hindcast_v2/
export SCRIPTS=/home/yzhou9/Scripts/SAForecast/hindcast_allyear_v2/template/

mkdir -p $LISRUN
mmmdd=oct28
for yyyy in `seq 2000 2018`; do
    cp $SCRIPTS/5.a.RunLISYear.sh $LISRUN/5.a.RunLISYear_$yyyy.sh
    cd $LISRUN
    sed -i "/^yyyy=/c\yyyy=$yyyy" 5.a.RunLISYear_$yyyy.sh
    sed -i "/^mmmdd=/c\mmmdd=$mmmdd" 5.a.RunLISYear_$yyyy.sh
    sed -i "/#SBATCH --job-name=/c\#SBATCH --job-name=$yyyy" 5.a.RunLISYear_$yyyy.sh
    sed -i "/SBATCH --error=/c\#SBATCH --error=forecast_$yyyy.err" 5.a.RunLISYear_$yyyy.sh
    sed -i "/SBATCH --output=/c\#SBATCH --output=forecast_$yyyy.log" 5.a.RunLISYear_$yyyy.sh
    sbatch -d afterany:34816364 5.a.RunLISYear_$yyyy.sh > $LISRUN/$yyyy/$mmmdd/JobID_OL.txt
done


