#!/bin/sh

#This script generates LIS simulation folder structure and initiate forecast simulation. This process includes: 1) Make a copy of folder template; 2) Run LDT to generate ensemble restart file. 3) Change LIS configure file and generate forcing folder structure. 4) Initiate forecast process.


#Set initial date of forecast and necessary paths
yyyy=2019
mmmdd=oct28
export WORKING=/data1/LISRUN/Forecast/
export FORECAST=$WORKING/ForecastRun/
export RETRO=/data1/LISRUN/Retro_NoahMP_GDAS_Chirp/NoahMP/SURFACEMODEL/
export FORCING=$WORKING/GEOS5_downscaled/

mkdir -p $FORECAST/$yyyy/$mmmdd

#Get total number of ensemble

nens=`ls -1d $FORCING/$yyyy/$mmmdd/ens* | wc -l`

#1) Make a copy of the template forecast folder.
rsync -a $WORKING/ForecastRun/forecast_template/ $FORECAST/$yyyy/$mmmdd/

# From the forecast initial date calculate the first LIS forecast date. The LIS forecast simulatio starts at the first day of next month of the GEOS-S2S forecast inital date.
cd $FORECAST/$yyyy/$mmmdd/RSTFILE
lyyyymm=`date -d "$mmmdd $yyyy +1 month" "+%Y%m"`
yyyymmdd=`date -d "${lyyyymm}01 -1 day" "+%Y%m%d"`
yyyymm=`echo $yyyymmdd | cut -b1-6`
#Link the restart file from retrospective simulation to further generate ensemble restart file for forecast.
ln -sf $RETRO/$yyyymm/LIS_RST_NOAHMP36_${yyyymmdd}2345.d01.nc .

#2) Modify and run LDT configure file to generate ensemble restart file.
cd $FORECAST/$yyyy/$mmmdd
sed -i "s/^\(Input restart filename:\).*/\1        .\/RSTFILE\/LIS_RST_NOAHMP36_${yyyymmdd}2345.d01.nc/" ldt.config.ensemble
sed -i "s/^\(Output restart filename:\).*/\1        .\/RSTFILE\/LIS_ensrst_NOAHMP36_${yyyymmdd}2345.d01.nc/" ldt.config.ensemble
sed -i "s/^\(Number of ensembles per tile (output restart):\).*/\1 $nens/" ldt.config.ensemble
sh run_LDT_ensemble.sh 

#3) Modify LIS configure file with proper restart file path, starting year/month/day, total ensemble number and ending year/month/day.
sed -i "s/^\(Noah-MP.3.6 restart file:\).*/\1        .\/RSTFILE\/LIS_ensrst_NOAHMP36_${yyyymmdd}2345.d01.nc/" lis.config.noahmp.ensemble 
yyyymmdd=`date -d "${yyyymm}01 +1month" "+%Y%m%d"`
yy=`echo $yyyymmdd | cut -b1-4`
mm=`echo $yyyymmdd | cut -b5,6`
dd=`echo $yyyymmdd | cut -b7,8`

sed -i "s/^\(Starting year:\).*/\1                             $yy/" lis.config.noahmp.ensemble
sed -i "s/^\(Starting month:\).*/\1                            $mm/" lis.config.noahmp.ensemble
sed -i "s/^\(Starting day:\).*/\1                              $dd/" lis.config.noahmp.ensemble
sed -i "s/^\(Number of ensembles per tile:\).*/\1   $nens/" lis.config.noahmp.ensemble
sed -i "s/^\(Generic ensemble forecast number of ensemble members:\).*/\1     $nens/" lis.config.noahmp.ensemble
sed -i "s/^\(Precipitation ensemble forecast number of ensemble members:\).*/\1     $nens/" lis.config.noahmp.ensemble

NYYYY=`date -d "$yy-$mm-01 +9months" "+%Y"`
NMM=`date -d "$yy-$mm-01 +9months" "+%m"`  
sed -i "/^[^#]/s/\(Ending year:\).*/\1                               $NYYYY/" lis.config.noahmp.ensemble
sed -i "/^[^#]/s/\(Ending month:\).*/\1                              $NMM/" lis.config.noahmp.ensemble
sed -i "/^[^#]/s/\(Ending day:\).*/\1                                01/" lis.config.noahmp.ensemble 

#3) Generate forcing folder structure.
mkdir -p $FORECAST/$yyyy/$mmmdd/FORCING/$yyyy/$mmmdd/
cd $FORCING/$yyyy/$mmmdd/
i=1
for ens in `ls -1d ens*`; do
    ln -s $FORCING/$yyyy/$mmmdd/$ens/ $FORECAST/$yyyy/$mmmdd/FORCING/$yyyy/$mmmdd/ens$i
    i=$(($i+1))
done
#LIS only search for data in the folder matches starting year and month. Link forcing data to all month in case we need to restart the forecast from another month. 
cd $FORECAST/$yyyy/$mmmdd/FORCING/$yyyy/
mon=( jan feb mar apr may jun jul aug sep oct nov dec )
for mmm in "${mon[@]}"; do
    ln -s $mmmdd ${mmm}01
done

cd $FORECAST/$yyyy/$mmmdd/FORCING/
yyyy1=`date -d "${yyyy}0101 + 1year"  "+%Y"`
ln -s $yyyy $yyyy1

#4) Initialize the LIS forecast simulation.
cd $FORECAST/$yyyy/$mmmdd/
sh run_LIS_ensemble.sh



