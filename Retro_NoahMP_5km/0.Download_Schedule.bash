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
csh ConvertData.csh			#Convert GRIB1 data to GRIB2 
echo "Converting data done" 
#cd $FOLDER
#bash RunLIS.bash > log.txt	#Run LIS!
