#!/bin/sh

#SBATCH --job-name=f_mon_s
#SBATCH --output=./logs/stats_%a.log
#SBATCH --error=./logs/stats_%a.err
#SBATCH --time=12:00:00
#SBATCH --account s1525
#SBATCH --ntasks=28
#SBATCH --mail-user=yzhou65@jhu.edu
#SBATCH --mail-type=ALL
#SBATCH --array=5-11

export WORKING=/discover/nobackup/projects/grace/
export LISRUN=/discover/nobackup/projects/grace/Yifan/LISRUN/
export HINDCAST=$LISRUN/SALDAS/Forecast/hindcast_v1/
export CLIM=$HINDCAST/hindcast_CLIM/

ulimit -v unlimited

module purge
module load other/nco-4.6.8-gcc-5.3-sp3

#vars=( Tair_f_tavg ) #Rainf_f_tavg Evap_tavg SoilMoist_inst Tair_f_tavg_min Tair_f_tavg_max ) 
vars=( SoilMoist_inst Tair_f_tavg Rainf_f_tavg Evap_tavg TWS_inst Snowcover_inst Tair_f_tavg_min Tair_f_tavg_max )

echo "Calculating average and std"
cd $CLIM/middle/alltime

mm=`printf %02d $SLURM_ARRAY_TASK_ID`
maxdd=`cal $mm 2019 | awk 'NF {DAYS = $NF}; END {print DAYS}'`

mkdir -p $CLIM/middle/monthly/$mm/
cd $CLIM/middle/monthly/$mm/
for var in "${vars[@]}"; do
    echo "chekcing $mm $var"
    for yyyy in `seq 2000 2017`; do
        for e in `seq 0 9`; do
            {
            eval ln -sf $CLIM/middle/alltime/${var}_$yyyy$mm??.ens$e.nc .
            find ${var}_$yyyy$mm??.ens$e.nc -xtype l -delete
            echo "  submitting $yyyy $mm ens$e $var"

            ncea -h ${var}_$yyyy$mm??.ens$e.nc -O ${var}_$yyyy$mm.ens$e.nc
            find . -maxdepth 1 -type l  -name "${var}_$yyyy$mm??.ens$e.nc" -delete
            echo "  $yyyy $mm ens$e $var done"
            }&
            sleep 0.6s
        done
    done
    wait
    echo "all $mm $var done"
    {
    echo "$mm $var avg & std"
    ncecat -h ${var}_??????.ens?.nc -O $var.$mm.alltime.nc
    rm ${var}_??????.ens?.nc
    ncwa -h -a record $var.$mm.alltime.nc -O $var.$mm.avg.nc
    ncdiff -h $var.$mm.alltime.nc $var.$mm.avg.nc -O $var.$mm.diff.nc
    rm $var.$mm.alltime.nc

    ncra -h -y rmssdn $var.$mm.diff.nc -O $var.$mm.std.1d.nc
    rm $var.$mm.diff.nc
    ncwa -h -a record $var.$mm.std.1d.nc -O $var.$mm.std.nc
    rm $var.$mm.std.1d.nc

#    if [ "$var" == "Tair_f_tavg" ];
#    then
#        cp $var.$mm.avg.nc monthly.$mm.avg.nc
#        cp $var.$mm.std.nc monthly.$mm.std.nc
#    else
#        ncks -h -A $var.$mm.avg.nc monthly.$mm.avg.nc
#        ncks -h -A $var.$mm.std.nc monthly.$mm.std.nc
#    fi
    echo "$mm $var avg & std done!!!"
    }&
    sleep 15s
done
wait
mkdir -p $CLIM/monthly
#mv monthly.$mm.avg.nc $CLIM/monthly/
#mv monthly.$mm.avg.nc $CLIM/monthly/
mv *.??.avg.nc $CLIM/monthly/
mv *.??.std.nc $CLIM/monthly/
echo "$mm $var done"

