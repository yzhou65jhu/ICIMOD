#!/bin/sh

mmmdd=oct28
export WORKING=/data1/LISRUN/Forecast/
export CLIM=$WORKING/hindcast_CLIM/$mmmdd/

ulimit -v unlimited

vars=( Tair_f_tavg Rainf_f_tavg Evap_tavg SoilMoist_inst ) 

echo "Calculating average and std"
cd $CLIM/middle/alltime


for dm in `seq 1 7`; do
    mm0=`date -d "$mmmdd 2019 +${dm}month" "+%m"`
    mm1=`printf %02d $((10#$mm0+1))`
    mm2=`printf %02d $((10#$mm1+1))`

    mkdir -p $CLIM/middle/3monthly/$mm0$mm1$mm2/
    cd $CLIM/middle/3monthly/$mm0$mm1$mm2/
    for var in "${vars[@]}"; do
        {
        echo "chekcing $var for month $mm0"
        echo "  checking $var $mm0 seperate ensembles"
        for yyyy in `seq 2000 2018`; do
            yyyymm0=`date -d "$mmmdd $yyyy +${dm}month" "+%Y%m"`
            yyyymm1=`date -d "$mmmdd $yyyy +${dm}month" "+%Y%m"`
            yyyymm2=`date -d "$mmmdd $yyyy +${dm}month" "+%Y%m"`
            sdd=${sdds[$i]}
            edd=${edds[$i]}
            ende=7
            if [ $yyyy$mm -le 201709 ]; then
                ende=0
            fi
            for e in `seq 0 $ende`; do
                eval ln -sf $CLIM/middle/alltime/${var}_$yyyymm0??.ens$e.nc .
                eval ln -sf $CLIM/middle/alltime/${var}_$yyyymm1??.ens$e.nc .
                eval ln -sf $CLIM/middle/alltime/${var}_$yyyymm2??.ens$e.nc .
                find ${var}_$yyyymm0??.ens$e.nc -xtype l -delete
                find ${var}_$yyyymm1??.ens$e.nc -xtype l -delete
                find ${var}_$yyyymm2??.ens$e.nc -xtype l -delete

                ncea -h ${var}_20??????.ens$e.nc -O ${var}_$yyyy$mm0$mm1$mm2.ens$e.nc
                find . -maxdepth 1 -type l  -name "${var}_$yyyymm0??.ens$e.nc" -delete
                find . -maxdepth 1 -type l  -name "${var}_$yyyymm1??.ens$e.nc" -delete
                find . -maxdepth 1 -type l  -name "${var}_$yyyymm2??.ens$e.nc" -delete
            done
        done
        echo "  calculating $var $mm0 stats"
        ncecat -h ${var}_20??$mm0$mm1$mm2.ens?.nc -O $var.$mm0$mm1$mm2.alltime.nc
        rm ${var}_20??$mm0$mm1$mm2.ens?.nc
        ncwa -h -a record $var.$mm0$mm1$mm2.alltime.nc -O $var.$mm0$mm1$mm2.avg.nc
        ncdiff -h $var.$mm0$mm1$mm2.alltime.nc $var.$mm0$mm1$mm2.avg.nc -O $var.$mm0$mm1$mm2.diff.nc
        rm $var.$mm0$mm1$mm2.alltime.nc

        ncra -h -y rmssdn $var.$mm0$mm1$mm2.diff.nc -O $var.$mm0$mm1$mm2.std.1d.nc
        rm $var.$mm0$mm1$mm2.diff.nc
        ncwa -h -a record $var.$mm0$mm1$mm2.std.1d.nc -O $var.$mm0$mm1$mm2.std.nc
        rm $var.$mm0$mm1$mm2.std.1d.nc

        mkdir -p $CLIM/3monthly
        mv $var.$mm0$mm1$mm2.???.nc $CLIM/3monthly/
        echo "$var for month $mm0 done"
        } & 
        sleep 5s
    done
done
wait
echo "All done!"
