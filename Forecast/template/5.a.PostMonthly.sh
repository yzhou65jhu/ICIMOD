#!/bin/sh
# This script calculate the 
yyyy=2018
mmmdd=oct28

export WORKING=/data1/LISRUN/Forecast/
export CLIM=$WORKING/hindcast_CLIM/
export FORECAST=$WORKING/ForecastRun/$yyyy/$mmmdd/Noah3.6MP_ensemble/
export SC=`pwd`

function correct {
    file=$1
    date=$2

    cdo -s -L setgrid,$WORKING/grids/5kmgrid  -settaxis,$date,00:00:00 -setreftime,$date,00:00:00 $file $file.bak 1>NUL 2>NUL

    mv $file.bak $file
}

function selectens {
    file=$1
    i=$2
    name=${file%???}
    ncks -d lev,$i,$i $file -O $name.ens$i.nc
    ncwa -a lev $name.ens$i.nc -O $name.ens$i.nc
    ncks -x -v lev $name.ens$i.nc -O $name.ens$i.nc
}

vars=( Rainf_f_tavg Tair_f_tavg SoilMoist_inst Evap_tavg )

cd $FORECAST/SURFACEMODEL/
for yyyymm in `ls -1d 20????`; do
    {
    mkdir -p $FORECAST/Anomaly/monthly/middle
    cd $FORECAST/Anomaly/middle/
    echo "begin month $yyyymm"
    echo "month $yyyymm merging and averaging"
    nc=`ls -1 *.$yyyymm??.nc | wc -l`
    if [ $nc -gt 12 ]; then
        for var in "${vars[@]}"; do
            mm=`echo $yyyymm | cut -b5,6`
            cd $FORECAST/Anomaly/middle/
            rm -f $FORECAST/Anomaly/monthly/middle/daily.$var.$yyyymm.nc
            cdo -L -O -s cat $var.$yyyymm??.nc $FORECAST/Anomaly/monthly/middle/daily.$var.$yyyymm.nc
            cd $FORECAST/Anomaly/monthly/middle/
            cdo -L -O -s timavg daily.$var.$yyyymm.nc monthly.$var.$yyyymm.nc
            rm daily.$var.$yyyymm.nc
            ncrename -O -d x,east_west monthly.$var.$yyyymm.nc 1>NUL
            ncrename -O -d y,north_south monthly.$var.$yyyymm.nc 1>NUL

            echo "month $var $yyyymm : calculating monthly statistics"
            ncdiff monthly.$var.$yyyymm.nc $CLIM/monthly/$var.$mm.avg.nc -O $var.monthly.anomaly.$yyyymm.nc
            rm monthly.$var.$yyyymm.nc
            ncbo --op_typ=/ $var.monthly.anomaly.$yyyymm.nc $CLIM/monthly/$var.$mm.std.nc -O $var.monthly.std_anomaly.$yyyymm.nc
            ncwa -a ensemble $var.monthly.anomaly.$yyyymm.nc -O $var.monthly.anomaly.$yyyymm.ensmean.nc
            ncwa -a ensemble $var.monthly.std_anomaly.$yyyymm.nc -O $var.monthly.std_anomaly.$yyyymm.ensmean.nc

            echo "month $var $yyyymm : correcting files"
            date=$yyyy-$mm-01

            cdo -L -s setvrange,-30,30 $var.monthly.std_anomaly.$yyyymm.nc $var.monthly.std_anomaly.$yyyymm.nc.bak 2>NUL
            mv $var.monthly.std_anomaly.$yyyymm.nc.bak $var.monthly.std_anomaly.$yyyymm.nc

            cdo -L -s setvrange,-30,30 $var.monthly.std_anomaly.$yyyymm.ensmean.nc var.monthly.std_anomaly.$yyyymm.ensmean.nc.bak 2>NUL
            mv var.monthly.std_anomaly.$yyyymm.ensmean.nc.bak $var.monthly.std_anomaly.$yyyymm.ensmean.nc
            

            correct $var.monthly.anomaly.$yyyymm.nc $date
            correct $var.monthly.std_anomaly.$yyyymm.nc $date
            correct $var.monthly.anomaly.$yyyymm.ensmean.nc $date
            correct $var.monthly.std_anomaly.$yyyymm$dd.ensmean.nc $date

            echo "month $var $yyyymm : seperating ensemble"
            for i in `seq 0 6`; do
               selectens $var.monthly.anomaly.$yyyymm.nc $i
               selectens $var.monthly.std_anomaly.$yyyymm.nc $i
            done
            rm $var.monthly.anomaly.$yyyymm.nc $var.monthly.std_anomaly.$yyyymm.nc
    	done
        
        echo "$yyyymm: change SM unit"
        for file in `ls -1 SoilMoist_inst.monthly.anomaly.$yyyymm.ens*.nc`; do
            cdo -L -s divc,0.01 $file $file.bak
            ncatted -a units,SoilMoist_inst,m,c,"%" $file.bak -O $file
            mv $file.bak $file
        done

        echo "$yyyymm: change Rainfall unit"
        for file in `ls -1 Rainf_f_tavg.monthly.anomaly.$yyyymm.ens*.nc`; do
            ncap2 -s "Rainf_f_tavg=Rainf_f_tavg*86400*30;" $file -O $file
            ncatted -a units,Rainf_f_tavg,m,c,"kg m-2 mo-1" $file
        done

        echo "$yyyymm: change ET unit"
        for file in `ls -1 Evap_tavg.monthly.anomaly.$yyyymm.ens*.nc`; do
            ncap2 -s "Evap_tavg=Evap_tavg*86400*30;" $file -O $file
            ncatted -a units,Evap_tavg,m,c,"kg m-2 mo-1" $file
        done

        enss=( ensmean ens0 ens1 ens2 ens3 ens4 ens5 ens6 )
        catos=( anomaly std_anomaly )
        echo "Merging"
        for ens in "${enss[@]}"; do
            for cato in "${catos[@]}"; do
                cdo -L -s merge *.monthly.$cato.$yyyymm.$ens.nc $FORECAST/Anomaly/monthly/monthly.$cato.$yyyymm.$ens.nc
                rm *.monthly.$cato.$yyyymm.$ens.nc
            done
        done
    fi
    } &
    sleep 30s
done
wait

