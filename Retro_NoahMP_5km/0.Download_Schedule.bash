#!/bin/bash
FOLDER=~/data1/SCRIPTS/GDAS
SCRIPTS=/home/kshakya/data1/SCRIPTS/Retro_NoahMP_5km/
source ~/.bashrc

cd $SCRIPTS
echo "Fetcing the data"
csh FetchData.csh 			#Fetch the data
echo "Fetching data finished"
cd $SCRIPTS
echo "Coverting GDAS data" 
#There is a bug in ConvertData.csh to cause random error when run cnvgrib. Run this script multiple time to ensure no corrupted files. 
csh ConvertData.csh			#Convert GRIB1 data to GRIB2 
csh ConvertData.csh			#Convert GRIB1 data to GRIB2 
csh ConvertData.csh			#Convert GRIB1 data to GRIB2 
csh ConvertData.csh			#Convert GRIB1 data to GRIB2 
csh ConvertData.csh			#Convert GRIB1 data to GRIB2 
csh ConvertData.csh			#Convert GRIB1 data to GRIB2 
echo "Converting data done" 


