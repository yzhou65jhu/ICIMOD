#!/bin/bash
FOLDER=/data1/SCRIPTS/GDAS
source ~/.bashrc

cd $FOLDER
csh FetchData.csh			#Fetch the data
cd $FOLDER				
csh ConvertData.csh			#Convert GRIB1 data to GRIB2 
cd $FOLDER
bash RunLIS.bash > log.txt	#Run LIS!
