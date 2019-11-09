#!/bin/sh

#SBATCH --job-name=f3monens
#SBATCH --output=./logs/stats_mean_%a.log
#SBATCH --error=./logs/stats_mean_%a.err
#SBATCH --time=12:00:00
#SBATCH --account s1525
#SBATCH --ntasks=28
#SBATCH --mail-user=yzhou65@jhu.edu
#SBATCH --mail-type=ALL
#SBATCH --array=5-9

export WORKING=/discover/nobackup/projects/grace/
export LISRUN=/discover/nobackup/projects/grace/Yifan/LISRUN/
export HINDCAST=$LISRUN/SALDAS/Forecast/hindcast_v1/
export CLIM=$HINDCAST/hindcast_CLIM/

ulimit -v unlimited

module purge
module load other/nco-4.6.8-gcc-5.3-sp3

vars=( Tair_f_tavg Rainf_f_tavg Evap_tavg SoilMoist_inst Tair_f_tavg_min Tair_f_tavg_max ) 

echo "Calculating average and std"
cd $CLIM/middle/alltime

mm0=`printf %02d $SLURM_ARRAY_TASK_ID`
mm1=`printf %02d $((10#$mm0+1))`
mm2=`printf %02d $((10#$mm1+1))`

mkdir -p $CLIM/middle/3monthly/$mm0$mm1$mm2/ensmean/
cd $CLIM/middle/3monthly/$mm0$mm1$mm2/ensmean/
for var in "${vars[@]}"; do
    echo "chekcing $mm $var"
    for yyyy in `seq 2000 2017`; do
        {
        echo "  submitting $yyyy $mm ensmean $var"
        eval ln -sf $CLIM/middle/alltime/${var}_{$yyyy$mm0..$yyyy$mm2}??.ensmean.nc .
        find ${var}_$yyyy????.ensmean.nc -xtype l -delete

        case ${var: -3} in 
            "max")
            ncea -h -y max ${var}_$yyyy????.ensmean.nc -O ${var}_$yyyy$mm0$mm1$mm2.ensmean.nc
            ;;
            "min")
            ncea -h -y min ${var}_$yyyy????.ensmean.nc -O ${var}_$yyyy$mm0$mm1$mm2.ensmean.nc 
            ;;
            *)
            ncea -h ${var}_$yyyy????.ensmean.nc -O ${var}_$yyyy$mm0$mm1$mm2.ensmean.nc
        esac
        find . -maxdepth 1 -type l  -name "${var}_$yyyy????.ensmean.nc" -delete
        echo "  $yyyy $mm ensmean $var done"
        }&
        sleep 2s
    done
    wait
    echo "all $mm $var done"
    {
    echo "$mm $var avg & std"
    ncecat -h ${var}_20??$mm0$mm1$mm2.ensmean.nc -O $var.$mm0$mm1$mm2.alltime.nc
    rm ${var}_20??$mm0$mm1$mm2.ensmean.nc
    ncwa -h -a record $var.$mm0$mm1$mm2.alltime.nc -O $var.$mm0$mm1$mm2.avg.nc
    ncdiff -h $var.$mm0$mm1$mm2.alltime.nc $var.$mm0$mm1$mm2.avg.nc -O $var.$mm0$mm1$mm2.diff.nc
    rm $var.$mm0$mm1$mm2.alltime.nc

    ncra -h -y rmssdn $var.$mm0$mm1$mm2.diff.nc -O $var.$mm0$mm1$mm2.std.1d.nc
    rm $var.$mm0$mm1$mm2.diff.nc
    ncwa -h -a record $var.$mm0$mm1$mm2.std.1d.nc -O $var.$mm0$mm1$mm2.std.nc
    rm $var.$mm0$mm1$mm2.std.1d.nc

    if [ "$var" == "Tair_f_tavg" ];
    then
        cp $var.$mm0$mm1$mm2.avg.nc 3monthly.$mm0$mm1$mm2.avg.nc
        cp $var.$mm0$mm1$mm2.std.nc 3monthly.$mm0$mm1$mm2.std.nc
    else
        ncks -h -A $var.$mm0$mm1$mm2.avg.nc 3monthly.$mm0$mm1$mm2.avg.nc
        ncks -h -A $var.$mm0$mm1$mm2.std.nc 3monthly.$mm0$mm1$mm2.std.nc
    fi
    echo "$mm $var avg & std done!!!"
    }&
    sleep 45s
done
wait
mkdir -p $CLIM/3monthly/ensmean/
mv 3monthly.$mm0$mm1$mm2.avg.nc $CLIM/3monthly/ensmean/
mv 3monthly.$mm0$mm1$mm2.std.nc $CLIM/3monthly/ensmean/
echo "$mm $var done"

