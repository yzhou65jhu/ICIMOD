#!/bin/sh

mmmdd=oct28
export WORKING=/data1/LISRUN/Forecast/
export CLIM=$WORKING/hindcast_CLIM/$mmmdd/

ulimit -v unlimited

vars=( Tair_f_tavg Rainf_f_tavg Evap_tavg SoilMoist_inst Tair_f_tavg_min Tair_f_tavg_max ) 

echo "Calculating average and std"
cd $CLIM/middle/alltime

ms=( 11 12 01 02 03 04 05 06 07 )

for m in "${ms[@]}"; do
    mm=`printf %02d $m`
    maxdd=`cal $mm 2019 | awk 'NF {DAYS = $NF}; END {print DAYS}'`

    sdds=( 01 11 21 )
    edds=( 10 20 $maxdd )

    for i in "${!sdds[@]}"; do
        mkdir -p $CLIM/middle/dekad/$mm.$i/
        cd $CLIM/middle/dekad/$mm.$i/
        for var in "${vars[@]}"; do
            echo "chekcing $mm $i $var"
            for yyyy in `seq 2000 2018`; do
                sdd=${sdds[$i]}
                edd=${edds[$i]}
                ende=7
                if [ $yyyy$mm -le 201709 ]; then
                    ende=0
                fi
                for e in `seq 0 $ende`; do
                    {
                    eval ln -sf $CLIM/middle/alltime/${var}_{$yyyy$mm$sdd..$yyyy$mm$edd}.ens$e.nc .
                    find ${var}_$yyyy$mm??.ens$e.nc -xtype l -delete
                    echo "  submitting $yyyy $mm $i ens$e $var"

                    ncea -h ${var}_$yyyy$mm??.ens$e.nc -O ${var}_$yyyy$mm.$i.ens$e.nc
                    find . -maxdepth 1 -type l  -name "${var}_$yyyy$mm??.ens$e.nc" -delete
                    echo "  $yyyy $mm $i ens$e $var done"
                    }&
                    sleep 0.2s
                done
            done
            wait
            echo "all $mm $i $var done"
            {
            echo "$mm $i $var avg & std"
            ncecat -h ${var}_??????.$i.ens?.nc -O $var.$mm.$i.alltime.nc
            rm ${var}_??????.$i.ens?.nc
            ncwa -h -a record $var.$mm.$i.alltime.nc -O $var.$mm.$i.avg.nc
            ncdiff -h $var.$mm.$i.alltime.nc $var.$mm.$i.avg.nc -O $var.$mm.$i.diff.nc
            rm $var.$mm.$i.alltime.nc

            ncra -h -y rmssdn $var.$mm.$i.diff.nc -O $var.$mm.$i.std.1d.nc
            rm $var.$mm.$i.diff.nc
            ncwa -h -a record $var.$mm.$i.std.1d.nc -O $var.$mm.$i.std.nc
            rm $var.$mm.$i.std.1d.nc

            echo "$mm $i $var avg & std done!!!"
            }&
            sleep 5s
        done
        wait
        echo "$mm $i $var done"
    done
    mkdir -p $CLIM/dekad
    mv *.$mm.$i.avg.nc $CLIM/dekad/
    mv *.$mm.$i.std.nc $CLIM/dekad/
    echo "$mm $var done"
done
