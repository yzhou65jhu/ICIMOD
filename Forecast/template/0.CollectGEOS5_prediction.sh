#!/bin/sh
#This script is the zero step for the SLDAS Forecast product. This script downloads raw GEOS data
yyyy=2018
mmmdd=oct28

export WORKING=/data1/LISRUN/Forecast/
export GEOS=$WORKING/GEOS5/$yyyy/$mmmdd/

mkdir -p $GEOS/

cd $GEOS/

wget -r -np -nH -N -c --cut-dirs=4 -R "index.html*" https://gis1.servirglobal.net/data/geos_s2s/$yyyy/$mmmdd/

cd $GEOS/

for ensi in `ls -1d ens*`; do
    {
    cd $GEOS/$ensi
    mkdir -p onefile
    rm -f onefile/geos.$yyyy.$mmmdd.$ensi.allvariable.nc
    cdo -L -s mergetime *.nc4 onefile/geos.$yyyy.$mmmdd.$ensi.nc
    echo "$yyyy $mmmdd $ensi done"
    } &
    sleep 10s
done

wait
