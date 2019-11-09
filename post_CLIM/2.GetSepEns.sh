#!/bin/sh

#SBATCH --job-name=stats
#SBATCH --output=./logs/split_%a.log
#SBATCH --error=./logs/split_%a.err
#SBATCH --time=12:00:00
#SBATCH --account s1525
#SBATCH --ntasks=28
#SBATCH --mail-user=yzhou65@jhu.edu
#SBATCH --mail-type=ALL
#SBATCH --array=0-7

export WORKING=/discover/nobackup/projects/grace/
export LISRUN=/discover/nobackup/projects/grace/Yifan/LISRUN/
export HINDCAST=$LISRUN/SALDAS/Forecast/hindcast_v1/
export CLIM=$HINDCAST/hindcast_CLIM/
export SC=/home/yzhou9/Scripts/SAForecast/Post_LIS_CLIM/Forecast_sepens/

module purge
module load other/nco-4.6.8-gcc-5.3-sp3

echo "Getting individual ensemble members"
cd $CLIM/middle/alltime

files=( SoilMoist_inst Tair_f_tavg Rainf_f_tavg Evap_tavg TWS_inst Snowcover_inst Tair_f_tavg_min Tair_f_tavg_max )

abc=`date`
tstart=`date +%s`

function selectens {
    file=$1
    i=$2
    name=${file%???}
    module purge
    module load other/nco-4.6.8-gcc-5.3-sp3
    ncks -d ensemble,$i,$i $file -O $name.ens$i.nc
    ncwa -a ensemble $name.ens$i.nc -O $name.ens$i.nc
    ncks -x -v ensemble $name.ens$i.nc -O $name.ens$i.nc
}

#file_name=${files[$SLURM_ARRAY_TASK_ID]}

for file_name in "${files[@]}"; do

for file in `ls -1 ${file_name}_20??????.nc`; do
#for file in `ls -1 *_20??????.nc`; do
    yyyymmdd=`echo $file | cut -b5-12`
    {
        echo "submitting $file"
        for i in `seq 0 9`; do
            selectens $file $i
        done
        name=${file%???}
        ncwa -a ensemble $file -O $name.ensmean.nc
        rm $file
        echo "splitting $file done"
    } &
    sleep 0.5s
done
wait
done

wait
