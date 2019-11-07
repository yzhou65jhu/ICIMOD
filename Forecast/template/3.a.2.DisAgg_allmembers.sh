#!/bin/bash

yyyy=2018
mmmdd=oct28
i=1

export WORKING=/data1/LISRUN/Forecast
export GARDRUN=$WORKING/GARDRUN/$yyyy/$mmmdd
export GRIDS=$WORKING/grids
export PREDICTION=$WORKING/GEOS5_downscaled/$yyyy/$mmmdd/
export ADJUST=$PREDICTION/adjustment

VariableNames=( precip CRainf_f_tavg SWdown_f_tavg LWdown_f_tavg Tair_f_tavg Qair_f_tavg Psurf_f_tavg EWind_f_tavg NWind_f_tavg )
NewNames=( PRECTOT PRECCON SWGDN LWGAB T2M QV2M PS U10M V10M )

hours=( "00" "06" "12" "18" )

echo "1. Merge scale and diff data"
echo "    ens$i | Disaggregating ens$i"

cd $GARDRUN/ens$i/output/
echo "    correcting negative rainfall"
ncap2 -s "where(CRainf_f_tavg<0) CRainf_f_tavg=0;" mapped_out_CRain.nc -O mapped_out_CRain.nc
ncap2 -s "where(precip<0) precip=0;" mapped_out_precip.nc -O mapped_out_precip.nc

mkdir -p $PREDICTION/middle/ens$i
cd $PREDICTION/middle/ens$i
ln -sf $GARDRUN/ens$i/output/gard_out_*_tavg.nc .
ln -sf $GARDRUN/ens$i/output/mapped_out_precip.nc gard_out_precip.nc
ln -sf $GARDRUN/ens$i/output/mapped_out_CRain.nc gard_out_CRainf_f_tavg.nc

first_date=`date -d "$mmmdd $yyyy" "+%Y-%m-%d"`
echo "    removing reduntant files"

rm -f geos5_grided.nc
rm -f PRECTOT_grided.nc
rm -f daily.*.nc
rm -f *_newname.nc

for vari in ${!VariableNames[@]}; do
    var=${VariableNames[${vari}]}
    rm -f ${var}_alltime.nc
    rm -f ${var}_00.nc ${var}_06.nc ${var}_12.nc ${var}_18.nc
done


for vari in ${!VariableNames[@]}; do
    var=${VariableNames[${vari}]}

    echo "    ens$i:producing daily $var"
    cdo -L -s -b F64 settunits,minute -settaxis,${first_date},09:00:00,1d -setmissval,-9999.0 gard_out_$var.nc daily.$var.nc
    echo "    ens$i:Disaggregating $var"
    for hour in ${hours[@]}; do
        if [ $vari -eq 0 ]; then
            cdo -L -s settunits,minutes -settaxis,${first_date},${hour}:00:00,1d -mul daily.$var.nc $ADJUST/chirps_125_months_scale_${hour}_$var.nc ${var}_${hour}.nc
        else
            if [ $vari -le 2 ]; then
                cdo -L -s settunits,minutes -settaxis,${first_date},${hour}:00:00,1d -mul daily.$var.nc $ADJUST/gdas_125_months_scale_${hour}_$var.nc ${var}_${hour}.nc
            else
                cdo -L -s settunits,minutes -settaxis,${first_date},${hour}:00:00,1d -add daily.$var.nc $ADJUST/gdas_125_months_diff_${hour}_$var.nc ${var}_${hour}.nc
            fi
        fi
    done
    rm daily.$var.nc
    cdo -L -s mergetime ${var}_00.nc ${var}_06.nc ${var}_12.nc ${var}_18.nc ${var}_alltime.nc
    rm -f ${var}_??.nc
    cdo -L -s chname,${var},${NewNames[$vari]} ${var}_alltime.nc ${NewNames[$vari]}_newname.nc
    rm ${var}_alltime.nc
    
done

cd $PREDICTION/middle/ens$i
mv PRECTOT_newname.nc PRECTOT_nomiss.nc

cdo -L -O merge *_newname.nc geos5_allvariables.nc
rm *_newname.nc
cdo -L -O setgrid,$GRIDS/mygrid geos5_allvariables.nc geos5_grided.nc
rm geos5_allvariables.nc
cdo -L -O setgrid,$GRIDS/asiachirps5 PRECTOT_nomiss.nc PRECTOT_grided.nc
rm -f PRECTOT_nomiss.nc

