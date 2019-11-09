#!/bin/sh

yyyy=2019
mmmdd=oct28

export WORKING=/data1/LISRUN/Forecast/
export CLIM=$WORKING/hindcast_CLIM/
export FORECAST=$WORKING/ForecastRun/$yyyy/$mmmdd/Noah3.6MP_ensemble/
export SC=`pwd`

mkdir -p $FORECAST/Anomaly/middle/

#extract variables

vars=( Tair_f_tavg Rainf_f_tavg Evap_tavg )

cd $FORECAST/SURFACEMODEL/

for yyyymm in `ls -1d 20????`; do

    cd $FORECAST/SURFACEMODEL/$yyyymm

    for file in `ls LIS_HIST_${yyyymm}??????.d01.nc`; do
        yyyy=`echo $yyyymm | cut -b1-4`
        mm=`echo $yyyymm | cut -b5-6`
        dd=`echo $file | cut -b16-17`
        echo "begin SM_$yyyymm$dd"
        {
            cd $FORECAST/SURFACEMODEL/$yyyymm

            echo "$yyyymm$dd : extracting soil moisture"
            ncks -v SoilMoist_inst $file -O $FORECAST/Anomaly/middle/SM.$yyyymm$dd.nc

            echo "$yyyymm$dd : extracting other variables"
	    for var in "${vars[@]}"; do
	        cdo -L -s select,name=$var $file $FORECAST/Anomaly/middle/$var.$yyyymm$dd.nc
	    done

            cd $FORECAST/Anomaly/middle/
            ncks -A $SC/weights.nc SM.$yyyymm$dd.nc
            ncwa -a SoilMoist_profiles -d SoilMoist_profiles,0,2 -w SoilDepth -v SoilMoist_inst SM.$yyyymm$dd.nc -O SoilMoist_inst.$yyyymm${dd}.nc
            rm SM.$yyyymm$dd.nc

            echo "$yyyymm$dd done..."
        } &
        sleep 5s
    done
    wait
done


sed -i "s/^\(yyyy=\).*/\1$yyyy/" 5.a.PostMonthly.sh
sed -i "s/^\(mmmdd=\).*/\1$mmmdd/" 5.a.PostMonthly.sh
bash 5.a.PostMonthly.sh
