#!/bin/sh

#SBATCH --job-name=fdekens
#SBATCH --output=./logs/stats_mean_%a.log
#SBATCH --error=./logs/stats_mean_%a.err
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

vars=( Tair_f_tavg Rainf_f_tavg Evap_tavg SoilMoist_inst Tair_f_tavg_min Tair_f_tavg_max ) 

mm=`printf %02d $SLURM_ARRAY_TASK_ID`
maxdd=`cal $mm 2019 | awk 'NF {DAYS = $NF}; END {print DAYS}'`

sdds=( 01 11 21 )
edds=( 10 20 $maxdd )

for i in "${!sdds[@]}"; do
    mkdir -p $CLIM/middle/dekad/$mm.$i/ensmean/
    cd $CLIM/middle/dekad/$mm.$i/ensmean/
    for var in "${vars[@]}"; do
        echo "chekcing $mm $i $var"
        for yyyy in `seq 2000 2017`; do
            sdd=${sdds[$i]}
            edd=${edds[$i]}
            {
            eval ln -sf $CLIM/middle/alltime/${var}_{$yyyy$mm$sdd..$yyyy$mm$edd}.ensmean.nc .
            find ${var}_$yyyy$mm??.ensmean.nc -xtype l -delete
            echo "  submitting $yyyy $mm $i ensmean $var"

            case ${var: -3} in 
                "max")
                ncea -h -y max ${var}_$yyyy$mm??.ensmean.nc -O ${var}_$yyyy$mm.$i.ensmean.nc
                ;;
                "min")
                ncea -h -y min ${var}_$yyyy$mm??.ensmean.nc -O ${var}_$yyyy$mm.$i.ensmean.nc 
                ;;
                *)
                ncea -h ${var}_$yyyy$mm??.ensmean.nc -O ${var}_$yyyy$mm.$i.ensmean.nc
            esac
            find . -maxdepth 1 -type l  -name "${var}_$yyyy$mm??.ensmean.nc" -delete
            echo "  $yyyy $mm $i ensmean $var done"
            }&
            sleep 0.2s
        done
        wait
        echo "all $mm $i $var done"
        {
        echo "$mm $i $var avg & std"
        ncecat -h ${var}_??????.$i.ensmean.nc -O $var.$mm.$i.alltime.nc
        rm ${var}_??????.$i.ensmean.nc
        ncwa -h -a record $var.$mm.$i.alltime.nc -O $var.$mm.$i.avg.nc
        ncdiff -h $var.$mm.$i.alltime.nc $var.$mm.$i.avg.nc -O $var.$mm.$i.diff.nc
        rm $var.$mm.$i.alltime.nc

        ncra -h -y rmssdn $var.$mm.$i.diff.nc -O $var.$mm.$i.std.1d.nc
        rm $var.$mm.$i.diff.nc
        ncwa -h -a record $var.$mm.$i.std.1d.nc -O $var.$mm.$i.std.nc
        rm $var.$mm.$i.std.1d.nc

        if [ "$var" == "Tair_f_tavg" ];
        then
            cp $var.$mm.$i.avg.nc dekad.$mm.$i.avg.nc
            cp $var.$mm.$i.std.nc dekad.$mm.$i.std.nc
        else
            ncks -h -A $var.$mm.$i.avg.nc dekad.$mm.$i.avg.nc
            ncks -h -A $var.$mm.$i.std.nc dekad.$mm.$i.std.nc
        fi
        echo "$mm $i $var avg & std done!!!"
        }&
        sleep 5s
    done
    wait
    mkdir -p $CLIM/dekad/ensmean/
    mv dekad.$mm.$i.avg.nc $CLIM/dekad/ensmean/
    mv dekad.$mm.$i.std.nc $CLIM/dekad/ensmean/
    echo "$mm $i $var done"
done

