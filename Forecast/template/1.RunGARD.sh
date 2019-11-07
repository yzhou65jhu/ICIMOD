#!/bin/sh

#This script downscales raw GEOS5 with GARD algorithm. The main steps are: 1) make a copy of the downscale template folder and 2) run GARD for each of the variables. 

#Setting path variables. 
export WORKING=/data1/LISRUN/Forecast/    	#Main working folder
export COPYPATH=$WORKING/GEOS5/   		#Folder for raw GEOS5
export GARDRUN=$WORKING/GARDRUN/                #Folder for all GARD simulations
export SCRIPTS=`pwd`

#Setting date of the GEOS5 forecast. Change this for every forecast.
yyyy=2018
mmmdd=oct28
        
mkdir -p $GARDRUN/$yyyy/$mmmdd
cd $COPYPATH/$yyyy/$mmmdd

for ensi in `ls -d ens*`; do
    #1) Make a copy of template folder for each ensemble member path $GARDRUN/$yyyy/$mmmdd/$ensi
    echo "$yyyy $mmmdd $ensi"
    rsync -a $GARDRUN/template/ $GARDRUN/$yyyy/$mmmdd/$ensi
    cd $GARDRUN/$yyyy/$mmmdd/$ensi/prediction 
    #Link the prediction data, which are produced in the last script 0, to GARD downscale folder for each ensemble member. 
    ln -sf $COPYPATH/$yyyy/$mmmdd/$ensi/onefile/geos.$yyyy.$mmmdd.$ensi.nc prediction_data_ppt.nc
    ln -sf $COPYPATH/$yyyy/$mmmdd/$ensi/onefile/geos.$yyyy.$mmmdd.$ensi.nc prediction_data.nc

    #2) run GARD for each of the variables. 
    cd $GARDRUN/$yyyy/$mmmdd/$ensi/
    echo "$yyyy $mmmdd $ensi all"
    #Run GARD to downscale all variables except for precipitation or convective precipitation
    bash run_all.sh > logs/all.log 2>&1
    echo "$yyyy $mmmdd $ensi rain"
    #Run GARD to downscale precipitation and convective precipitation
    bash run_rains.sh > logs/rain.log  2>&1
    echo "$yyyy $mmmdd $ensi done"
done



