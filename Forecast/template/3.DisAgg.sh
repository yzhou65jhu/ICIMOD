#!/bin/bash
#This scripts disaggregate GARD-downscaled daily met forcing data into 6-hourly met forcing data. 
#The disaggregation process includes three steps:1) Combine climatology disaggregation files that have the same date range as the daily met forcing data; 2) Disaggregate daily met forcing data into 6-hourly by either subtracting the climatology difference or dividing the climatology ratio. 3) Change the naming convention and add necessary attributes. Those steps are further scripted into 3 files, 3.a.1.CombineAdjustFiles.sh, 3.a.2.DisAgg_allmembers.sh, 3.a.3.GenForcingFiles.sh.


#Set initial date of the forecast
yyyy=2018
mmmdd=oct28

#Set necessary paths
export SCRIPTS=`pwd`
export WORKING=/data1/LISRUN/Forecast/
export PREDICTION=$WORKING/GEOS5_downscaled/$yyyy/$mmmdd/
export GARDRUN=$WORKING/GARDRUN/$yyyy/$mmmdd/

mkdir -p $PREDICTION/logs

#1) Change the initial date in the first supplementary script and run the script to combine climatology disaggregation files.
cp $SCRIPTS/3.a.1.CombineAdjustFiles.sh $PREDICTION
cd $PREDICTION
sed -i "/yyyy=/c\yyyy=$yyyy" 3.a.1.CombineAdjustFiles.sh
sed -i "/mmmdd=/c\mmmdd=$mmmdd" 3.a.1.CombineAdjustFiles.sh
chmod +x 3.a.1.CombineAdjustFiles.sh
echo "Combining Adjust files"
echo "Check logs at $PRECITIOIN/logs/"
bash 3.a.1.CombineAdjustFiles.sh > ./logs/comb.log 2> ./logs/comb.err

cd $GARDRUN
for ens in `ls -1d ens*`; do
    mkdir -p $PREDICTION/middle/$ens

    #2) Copy the second supplementary script to each ensemble folder to disaggregate daily met forcing data for different ensemble member. 
    cp $SCRIPTS/3.a.2.DisAgg_allmembers.sh $PREDICTION/middle/$ens
    cd $PREDICTION/middle/$ens
    i=`echo $ens | cut -c4-`
    sed -i "/i=/c\i=$i" 3.a.2.DisAgg_allmembers.sh
    sed -i "/yyyy=/c\yyyy=$yyyy" 3.a.2.DisAgg_allmembers.sh
    sed -i "/mmmdd=/c\mmmdd=$mmmdd" 3.a.2.DisAgg_allmembers.sh
	
    #3) Copy the third supplementary script to each ensemble folder to change the naming conventions. 
    cp $SCRIPTS/3.a.3.GenForcingFiles.sh $PREDICTION/middle/$ens
    sed -i "/i=/c\i=$i" 3.a.3.GenForcingFiles.sh
    sed -i "/yyyy=/c\yyyy=$yyyy" 3.a.3.GenForcingFiles.sh
    sed -i "/mmmdd=/c\mmmdd=$mmmdd" 3.a.3.GenForcingFiles.sh


    echo "Disaggregating $ens"
    echo "check logs at $PREDICTION/middle/$ens/"
    {
    #Run disaggregation script
    bash 3.a.2.DisAgg_allmembers.sh > SubDis.log 2>&1 

    #Run name convention script 
    bash 3.a.3.GenForcingFiles.sh > Gen.log 2>&1
    echo "$ens done"
    } &
    sleep 20s
done

#wait until all simulations are done. 
wait

