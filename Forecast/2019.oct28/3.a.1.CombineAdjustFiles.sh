#!/bin/bash
#This script is the first supplementary script of the disaggregation step (see 3.DisAgg.sh for reference). This script combines climatology disaggregation files into one file for further disaggregation process which is described in the second supplementary script (i.e., 3.a.2.DisAgg_allmembers.sh). 

#Set the initial date of the forecast
yyyy=2000
mmmdd=oct28

#Set necessary paths
export WORKING=/data1/LISRUN/Forecast/
export GARDRUN=$WORKING/GARDRUN/$yyyy/$mmmdd
export GDASCLIM=$WORKING/gdas_correction/
export CHIRPSCLIM=$WORKING/chirps_correction/
export GRIDS=$WORKING/grids/
export PREDICTION=$WORKING/GEOS5_downscaled/$yyyy/$mmmdd/

#The variable names in the downscaled daily met forcing data
VariableNames=(  precip CRainf_f_tavg SWdown_f_tavg LWdown_f_tavg Tair_f_tavg Qair_f_tavg Psurf_f_tavg EWind_f_tavg NWind_f_tavg )

#The variable we needed for the LIS forecast simulation
NewNames=( PRECTOT PRECCON SWGDN LWGAB T2M QV2M PS U10M V10M )

hours=( "00" "06" "12" "18" )

echo "1. Merge scale and diff data"
mkdir -p $PREDICTION

#Set ensemble member to 1. We are only using ensemble that have 9-month data, so the climatology disaggregation (adjustment) files have the same date range. We then only need to generate one set of adjustment files for all ensemble members. 
i=1
echo "  Dealing with ens$i"
cd $GARDRUN
echo "    ens$i; Linking diff and scale data ens$i"
export ADJUST=$PREDICTION/adjustment
rm -rf $ADJUST

#Create a temporary working folder to generate adjustment files. 
mkdir -p $ADJUST/middle
export SAMPLE=$GARDRUN/ens$i
cd $SAMPLE/prediction
first_date=`cdo -L -s showdate prediction_data.nc | cut -d' ' -f3`
echo $first_date
names=""

#Find all dates in the raw GEOS-S2S prediction data (the downscaled daily data have the same date as the prediction data) and link corresponding adjustment files into the working folder. 
for date in `cdo -L -s showdate prediction_data.nc`; do
    mmdd=`echo $date | cut -b6,7,9,10`
    cd $ADJUST/middle
    ln -sf $GDASCLIM/gdas_125_$mmdd??_diff.nc .
    ln -sf $GDASCLIM/gdas_125_$mmdd??_scale.nc .
    ln -sf $CHIRPSCLIM/chirps_125_$mmdd??_scale.nc .
    names="$names _125_$mmdd"
    #chirps_names="$chirps_names chirps_125_$mmdd"
done



cd $ADJUST/middle
#Loop through different sub-daily time steps, 00, 06, 12, and 18. Generate the sub-daily files seperately for each time step. 
for hour in ${hours[@]}; do
    gdas_name_with_hours_diff=""
    gdas_name_with_hours_scale=""
    chirps_name_with_hours_scale=""

    #Generate an array of adjustment file names within forecast date range for $hour (e.g. 00)
    for name in $names; do
        gdas_name_with_hours_diff="$gdas_name_with_hours_diff gdas${name}${hour}_diff.nc"
        gdas_name_with_hours_scale="$gdas_name_with_hours_scale gdas${name}${hour}_scale.nc"
        chirps_name_with_hours_scale="$chirps_name_with_hours_scale chirps${name}${hour}_scale.nc"
    done
    echo "    ens$i | hour:$hour | Aggregating $hour files for ens$i"

    #Combine adjustment files into one file
    cdo -L -s cat $gdas_name_with_hours_diff gdas_125_months_diff_${hour}.nc &
    cdo -L -s cat $gdas_name_with_hours_scale gdas_125_months_scale_${hour}.nc&
    cdo -L -s cat $chirps_name_with_hours_scale chirps_125_months_scale_${hour}.nc &
    wait
    
    #Split the above files into seperate files for different variables.
    #Because disaggregation process can be different for each variable, we split the above files into seperate files for different variables. We use scale factor to disaggregate precipitation and convective precipitation and difference factor to disaggregate other variables. 
    for vari in ${!VariableNames[@]}; do
        {
        echo "calculating $hour $vari"
        varname=${VariableNames[${vari}]}
        if [ $vari -eq 0 ]; then
            cdo -L -s select,name=$varname chirps_125_months_scale_${hour}.nc ../chirps_125_months_scale_${hour}_$varname.nc
        else
            if [ $vari -le 2 ]; then
                cdo -L -s select,name=$varname gdas_125_months_scale_${hour}.nc ../gdas_125_months_scale_${hour}_$varname.nc
            else
                cdo -L -s select,name=$varname gdas_125_months_diff_${hour}.nc ../gdas_125_months_diff_${hour}_$varname.nc
            fi
        fi
        echo "$hour $varname done"
        }&
        sleep 1s
    done
    wait
done
wait

#remove the temperory file 
rm -r $ADJUST/middle


