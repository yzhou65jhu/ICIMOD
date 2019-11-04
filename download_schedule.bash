#!/bin/bash
FOLDER=~/data1/SCRIPTS/GDAS
LOGS=/home/kshakya/data1/SCRIPTS/logs/download_logs/
SCRIPTS=/home/kshakya/data1/SCRIPTS
source ~/.bashrc

date=`date | cut -d' ' -f6,2,3 | sed -e 's/ /_/g'`
file=$LOGS/download_${date}.log

cd $SCRIPTS
echo "Fetcing the data" >> $file
csh FetchData.csh >> $file  2>&1			#Fetch the data
echo "Fetching data finished" >> $file
cd $SCRIPTS
echo "Coverting GDAS data" >> $file
csh ConvertData.csh >> $file 2>&1			#Convert GRIB1 data to GRIB2 
echo "Converting data done" >> $file
#cd $FOLDER
#bash RunLIS.bash > log.txt	#Run LIS!
