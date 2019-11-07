#!/bin/bash

#This script is the second supplementary script of the disaggregation step (see 3.DisAgg.sh for reference). This script disaggregate daily met forcing to 6hourly met forcing. 

#Set initial forecast date ($yyyy and $mmmdd) and ensemble number ($i)
yyyy=2018
mmmdd=oct28
i=1

#Set necessary paths
export WORKING=/data1/LISRUN/Forecast
export GARDRUN=$WORKING/GARDRUN/$yyyy/$mmmdd
export GRIDS=$WORKING/grids
export PREDICTION=$WORKING/GEOS5_downscaled/$yyyy/$mmmdd/
export ADJUST=$PREDICTION/adjustment


#Variable names in downscaled data files
VariableNames=( precip CRainf_f_tavg SWdown_f_tavg LWdown_f_tavg Tair_f_tavg Qair_f_tavg Psurf_f_tavg EWind_f_tavg NWind_f_tavg )

#Variable names needed of the final forcings for LIS simulation.
NewNames=( PRECTOT PRECCON SWGDN LWGAB T2M QV2M PS U10M V10M )

#Subdaily time steps 
hours=( "00" "06" "12" "18" )

echo "1. Merge scale and diff data"
echo "    ens$i | Disaggregating ens$i"

cd $GARDRUN/ens$i/output/
echo "    correcting negative rainfall"

#After downscaling (and also before downscaling), there are small negative values in precipitation and convective precipitation files.
#Change those values to 0.
ncap2 -s "where(CRainf_f_tavg<0) CRainf_f_tavg=0;" mapped_out_CRain.nc -O mapped_out_CRain.nc
ncap2 -s "where(precip<0) precip=0;" mapped_out_precip.nc -O mapped_out_precip.nc

#Create a temperory working directory for disaggregation.
mkdir -p $PREDICTION/middle/ens$i
cd $PREDICTION/middle/ens$i

#Link daily met forcings to the working directory
ln -sf $GARDRUN/ens$i/output/gard_out_*_tavg.nc .
ln -sf $GARDRUN/ens$i/output/mapped_out_precip.nc gard_out_precip.nc
ln -sf $GARDRUN/ens$i/output/mapped_out_CRain.nc gard_out_CRainf_f_tavg.nc

#First_date is furthur used for setting dates in met forcings files. GARD output doesn't have date/time information. 
first_date=`date -d "$mmmdd $yyyy" "+%Y-%m-%d"`
echo "    removing reduntant files"

rm -f geos5_grided.nc
rm -f PRECTOT_grided.nc
rm -f daily.*.nc
rm -f *_newname.nc

#Delete old results if this script is rerun for whatever reason. 
for vari in ${!VariableNames[@]}; do
    var=${VariableNames[${vari}]}
    rm -f ${var}_alltime.nc
    rm -f ${var}_00.nc ${var}_06.nc ${var}_12.nc ${var}_18.nc
done

#Begin disaggregation for each variable
for vari in ${!VariableNames[@]}; do
    var=${VariableNames[${vari}]}

    echo "    ens$i:producing daily $var"
    #Set the date/time for daily met forcing so it can match with climatology disaggregation (adjustment) files.
    cdo -L -s -b F64 settunits,minute -settaxis,${first_date},09:00:00,1d -setmissval,-9999.0 gard_out_$var.nc daily.$var.nc
    echo "    ens$i:Disaggregating $var"

    #Calculate $hour 6hourly data based on daily data and climatology difference/ratio files. 
    for hour in ${hours[@]}; do
        if [ $vari -eq 0 ]; then
	    #Calculate $hour CHIRPS precipitation based ratio of climatology daily data to climatology $hour data
            cdo -L -s settunits,minutes -settaxis,${first_date},${hour}:00:00,1d -mul daily.$var.nc $ADJUST/chirps_125_months_scale_${hour}_$var.nc ${var}_${hour}.nc
        else
            if [ $vari -le 2 ]; then
	        #Calculate precipitation and solar radiation based on ratio
                cdo -L -s settunits,minutes -settaxis,${first_date},${hour}:00:00,1d -mul daily.$var.nc $ADJUST/gdas_125_months_scale_${hour}_$var.nc ${var}_${hour}.nc
            else
	        #Calculate other variables based on difference
                cdo -L -s settunits,minutes -settaxis,${first_date},${hour}:00:00,1d -add daily.$var.nc $ADJUST/gdas_125_months_diff_${hour}_$var.nc ${var}_${hour}.nc
            fi
        fi
    done
    rm daily.$var.nc

    #Merge all 00 06 12 18 files into one file and sort the data based on date/time
    cdo -L -s mergetime ${var}_00.nc ${var}_06.nc ${var}_12.nc ${var}_18.nc ${var}_alltime.nc
    rm -f ${var}_??.nc
    
    #Change name to met forcing name that LIS reads. 
    cdo -L -s chname,${var},${NewNames[$vari]} ${var}_alltime.nc ${NewNames[$vari]}_newname.nc
    rm ${var}_alltime.nc
    
done

cd $PREDICTION/middle/ens$i
mv PRECTOT_newname.nc PRECTOT_nomiss.nc

cdo -L -O merge *_newname.nc geos5_allvariables.nc
rm *_newname.nc
#Add grid (lat/lon) information to the file.
cdo -L -O setgrid,$GRIDS/mygrid geos5_allvariables.nc geos5_grided.nc
rm geos5_allvariables.nc

#Add grid (lat/lon) information to precipitation file.
cdo -L -O setgrid,$GRIDS/asiachirps5 PRECTOT_nomiss.nc PRECTOT_grided.nc
rm -f PRECTOT_nomiss.nc

#End 3.a.2
