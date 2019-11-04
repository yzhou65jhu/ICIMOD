#!/bin/bash

export WORKING=/home/kshakya/data1/
export MET_FORCING=$WORKING/MET_FORCING
export CHIRPSv2=$MET_FORCING/CHIRPSv2/daily_p05
export SC=$WORKING/SCRIPTS/Retro_NoahMP_5km
export LISRUN=$WORKING/LISRUN
export RETRO_OUT=$LISRUN//Retro_NoahMP_GDAS_Chirps/NoahMP/SURFACEMODEL/
export CHIRPS_DIS=$LISRUN/CHIRPS_diurnal

cd $CHIRPSv2
date
echo "--------------Downloadig chirps--------------"
wget -N -c ftp://chg-ftpout.geog.ucsb.edu/pub/org/chg/products/CHIRPS-2.0/global_daily/netcdf/p05/chirps-v2.0*

echo "-------------Getting chirps starting date----------------"
cd $RETRO_OUT
yyyymm=`ls -1d 20* | sort | tail -n 1`
cd $RETRO_OUT/$yyyymm/
dd=`ls -1 LIS_HIST_$yyyymm??????.d01.nc | tail -n 1 | cut -b16,17`
echo "$yyyymm"
yyyy=${yyyymm%??}
mm=${yyyymm: -2}
ddate="$yyyy-$mm-$dd"
yyyy=`date -d "$ddate -1day" "+%Y"`
mm=`date -d "$ddate -1day" "+%m"`
dd=`date -d "$ddate -1day" "+%d"`

echo "--------------Modifying LIS CHIRPS starting date----------------"
cd $CHIRPS_DIS
sed -i "/^[^#]/s/\(Starting year:\).*/\1                        $yyyy/" ldt.config.CHIRPS_GDAS.6h
sed -i "/^[^#]/s/\(Starting month:\).*/\1                       $mm/" ldt.config.CHIRPS_GDAS.6h
sed -i "/^[^#]/s/\(Starting day:\).*/\1                         $dd/" ldt.config.CHIRPS_GDAS.6h
echo "Starting date: $yyyy $mm $dd"

cd $CHIRPSv2/
file=`ls -1 chirps-v2.0.20??.days_p05.nc | sort |tail -n 1`
dates=`cdo -s -L showdate $file`
ld=${dates##* }
yyyy=${ld:0:4}
mm=${ld:5:2}
dd=${ld:(-2)}

ddate="$yyyy-$mm-$dd"
yyyy=`date -d "$ddate +1day" "+%Y"`
mm=`date -d "$ddate +1day" "+%m"`
dd=`date -d "$ddate +1day" "+%d"`



cd $CHIRPS_DIS

sed -i "/^[^#]/s/\(Ending year:\).*/\1                          $yyyy/" ldt.config.CHIRPS_GDAS.6h
sed -i "/^[^#]/s/\(Ending month:\).*/\1                         $mm/" ldt.config.CHIRPS_GDAS.6h
sed -i "/^[^#]/s/\(Ending day:\).*/\1                           $dd/" ldt.config.CHIRPS_GDAS.6h
echo "Ending date : $yyyy $mm $dd"

echo "---------------Running LDT to get 6h CHIRPS-------------------"

./LDT ldt.config.CHIRPS_GDAS.6h




