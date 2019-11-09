#!/bin/sh


## Specify a name for the job allocation
#SBATCH --job-name=fdayEns
## Specify a filename for standard output
#SBATCH --output=./logs/stats_mean_%a.log
## Specify a filename for standard error
#SBATCH --error=./logs/stats_mean_%a.err
## Set a limit on the total run time
#SBATCH --time=12:00:00
## Enter NCCS Project ID below:
#SBATCH --account s1525
## Adjust node, core, and hardware constraints
#SBATCH --ntasks=28
##SBATCH --nodes=1
## Set number of tasks ~ processes per node
## Set number of cpus (cores) per task (process)
##SBATCH --cpus-per-task=1
# Substitute your e-mail here
#SBATCH --mail-user=yzhou65@jhu.edu
#SBATCH --mail-type=ALL
# Set quality of service, if needed.
#SBATCH --array=5-11

export WORKING=/discover/nobackup/projects/grace/
export LISRUN=/discover/nobackup/projects/grace/Yifan/LISRUN/
export HINDCAST=$LISRUN/SALDAS/Forecast/hindcast_v1/
export CLIM=$HINDCAST/hindcast_CLIM/
export SC=/home/yzhou9/Scripts/SAForecast/Post_LIS_CLIM/Forecast_ClimIC/daily/

ulimit -v unlimited

module purge
module load other/nco-4.6.8-gcc-5.3-sp3

vars=( Tair_f_tavg Rainf_f_tavg Evap_tavg Tair_f_tavg_min Tair_f_tavg_max SoilMoist_inst )

echo "Calculating average and std"
#cd $CLIM/middle/alltime

mm=`printf %02d $SLURM_ARRAY_TASK_ID`
maxdd=`cal $mm 2019 | awk 'NF {DAYS = $NF}; END {print DAYS}'`

#for timeday in `seq 7 7`; do #212
#    mmdd=`date -d "20190501 + ${timeday}day" "+%m%d"`
for dd in `seq -w 1 $maxdd`; do

#for mmdd in `du -sh daily.$mm??.???.nc | grep -v "21M" | cut -f2 | cut -b7-10 | uniq`; do
    mmdd=$mm$dd
    {
    echo "checking $mmdd"
    mkdir -p $CLIM/middle/daily/$mmdd/ensmean/
    cd $CLIM/middle/daily/$mmdd/ensmean/
    rm -f *tmp
    for var in ${vars[@]}; do
        for dt in `seq -2 2`; do
            tmmdd=`date -d "2019$mmdd + ${dt}day" "+%m%d"`
            cd $CLIM/middle/alltime
            nf=`ls -1 ${var}_????${tmmdd}.ensmean.nc | wc -l`
            if [ "$nf" -gt 0 ]
            then
                cd $CLIM/middle/daily/$mmdd/ensmean/
                ln -sf $CLIM/middle/alltime/${var}_????${tmmdd}.ensmean.nc .
            fi
        done

        names_avg=""
        names_std=""

        cd $CLIM/middle/daily/$mmdd/ensmean/
        ncecat -h ${var}_20??????.ensmean.nc -O $var.$mmdd.alltime.nc
        rm ${var}_20??????.ensmean.nc
        ncwa -h -a record $var.$mmdd.alltime.nc -O $var.$mmdd.avg.nc
        ncdiff -h $var.$mmdd.alltime.nc $var.$mmdd.avg.nc -O $var.$mmdd.diff.nc
        rm $var.$mmdd.alltime.nc

        ncra -h -y rmssdn $var.$mmdd.diff.nc -O $var.$mmdd.std.1d.nc
        rm $var.$mmdd.diff.nc
        ncwa -h -a record $var.$mmdd.std.1d.nc -O $var.$mmdd.std.nc
        rm $var.$mmdd.std.1d.nc
        if [ "$var" == "Tair_f_tavg" ]; 
        then
            cp $var.$mmdd.avg.nc daily.$mmdd.avg.nc
            cp $var.$mmdd.std.nc daily.$mmdd.std.nc
        else
            ncks -h -A $var.$mmdd.avg.nc daily.$mmdd.avg.nc
            ncks -h -A $var.$mmdd.std.nc daily.$mmdd.std.nc
        fi
        echo " $var $mmdd done"
    done

    mkdir -p $CLIM/daily/ensmean/
    mv daily.$mmdd.avg.nc $CLIM/daily/ensmean/
    mv daily.$mmdd.std.nc $CLIM/daily/ensmean/
    echo "All variables for $mmdd done"

    } &
    sleep 0.5m
done
wait
