#!/bin/bash

export WORKING=/home/kshakya/data1/
export MET_FORCING=$WORKING/MET_FORCING
export CHIRPSv2=$MET_FORCING/CHIRPSv2/daily_p05
export SC=$WORKING/SCRIPTS/Retro_NoahMP_5km
export LISRUN=$WORKING/LISRUN
export RETRO_OUT=$LISRUN//Retro_NoahMP_GDAS_Chirps/NoahMP/SURFACEMODEL/
export CHIRP_DIS=$LISRUN/CHIRP_diurnal
export CHIRP_RAW=$MET_FORCING/CHIRP/raw/
export CHIRP_NC=$MET_FORCING/CHIRP/ncfiles/


cd $CHIRPSv2/
file=`ls -1 chirps-v2.0.20??.days_p05.nc | sort |tail -n 1`
dates=`cdo -s -L showdate $file`
ld=${dates##* }
ld=`date -d "$ld +1day" "+%Y-%m-%d"`
yyyy=${ld:0:4}
byyyy=$yyyy
mm=${ld:5:2}
dd=${ld:(-2)}

cd $CHIRP_RAW
wget -N -c ftp://ftp.chg.ucsb.edu/pub/org/chg/products/CHIRP/daily/$yyyy/chirp.$yyyy*

lyyyymm=`date "+%Y%m"`

dt=0
while [ "$lyyyymm" -gt "$yyyy$mm" ]; do
    nyyyymm="$yyyy-$mm"
    yyyy=`date -d "${nyyyymm}-01 +1month" "+%Y"`
    mm=`date -d "${nyyyymm}-01 +1month" "+%m"`
    wget -N -c ftp://ftp.chg.ucsb.edu/pub/org/chg/products/CHIRP/daily/$yyyy/chirp.$yyyy.$mm*
    
done


mkdir -p $CHIRP_NC
cd $CHIRP_NC
ls -1 chirp.????.??.??.nc4 | cut -b7-16 > files_dates_nc.txt
cd $CHIRP_RAW
ls -1 chirp.????.??.??.tif | cut -b7-16 > files_dates_raw.txt
comm -23 files_dates_raw.txt $CHIRP_NC/files_dates_nc.txt > add_files.txt

for date in `cat add_files.txt`; do
    echo "converting $date"
    file=chirp.$date.tif
    gdal_translate -of netCDF -co "FORMAT=nc4" $file $CHIRP_NC/chirp.$date.nc4
done

cd $CHIRP_NC
echo "merging to one file"
for y4 in `seq $byyyy $yyyy`; do
    rm chirp.alltime.$y4.nc4
    sleep 1s
    cdo -L cat chirp.${y4}*nc4 chirp.alltime.$y4.nc4
    sleep 4s
    cdo -L -s setreftime,1980-01-01,00:00:00 -settaxis,${y4}-01-01,00:00:00 -settunits,days chirp.alltime.$y4.nc4 chirp.$y4.days_p05.nc4
    ncrename -v lat,latitude chirp.$y4.days_p05.nc4
    ncrename -v lon,longitude chirp.$y4.days_p05.nc4
    ncrename -v Band1,precip chirp.$y4.days_p05.nc4
    mv chirp.$y4.days_p05.nc4 ../
done





cd $CHIRPSv2/
file=`ls -1 chirps-v2.0.20??.days_p05.nc | sort |tail -n 1`
dates=`cdo -s -L showdate $file`
ld=${dates##* }
ld=`date -d "$ld +1day" "+%Y-%m-%d"`
yyyy=${ld:0:4}
mm=${ld:5:2}
dd=${ld:(-2)}

echo "Starting date: $yyyy $mm $dd"

cd $CHIRP_DIS
sed -i "/^[^#]/s/\(Starting year:\).*/\1                        $yyyy/" ldt.config.CHIRP_GDAS.6h
sed -i "/^[^#]/s/\(Starting month:\).*/\1                       $mm/" ldt.config.CHIRP_GDAS.6h
sed -i "/^[^#]/s/\(Starting day:\).*/\1                         $dd/" ldt.config.CHIRP_GDAS.6h

cd $CHIRP_RAW
file=`ls -1 chirp.20??.??.??.tif | sort | tail -n 1`
lyyyy=${file:6:4}
lmm=${file:11:2}
ldd=${file:14:2}
ldate="${lyyyy}-${lmm}-${ldd}"

yyyy=`date -d "$ldate +1day" "+%Y"`
mm=`date -d "$ldate +1day" "+%m"`
dd=`date -d "$ldate +1day" "+%d"`


cd $CHIRP_DIS

echo "Ending date: $yyyy $mm $dd"

sed -i "/^[^#]/s/\(Ending year:\).*/\1                          $yyyy/" ldt.config.CHIRP_GDAS.6h
sed -i "/^[^#]/s/\(Ending month:\).*/\1                         $mm/" ldt.config.CHIRP_GDAS.6h
sed -i "/^[^#]/s/\(Ending day:\).*/\1                           $dd/" ldt.config.CHIRP_GDAS.6h

echo "Running LDT"
./LDT ldt.config.CHIRP_GDAS.6h







