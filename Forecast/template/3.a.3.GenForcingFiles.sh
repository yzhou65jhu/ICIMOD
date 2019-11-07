#!/bin/sh
i=1
yyyy=2018
mmmdd=oct28

export WORKING=/home/kshakya/data1/LISRUN/Forecast/
export GEOS=$WORKING/GEOS5_downscaled/$yyyy/$mmmdd

    n=$i
    cd $GEOS/middle/ens$n
    echo "Dealing with ens$n"
    echo "  Merging geos ens$n"
    ncatted -O -a units,LWGAB,c,c,'W/m^2' geos5_grided.nc
    ncatted -O -a units,SWGDN,c,c,'W/m^2' geos5_grided.nc
    ncatted -O -a units,PS,c,c,'Pa' geos5_grided.nc
    ncatted -O -a units,QV2M,c,c,'kg/kg' geos5_grided.nc
    ncatted -O -a units,T2M,c,c,'K' geos5_grided.nc
    ncatted -O -a units,U10M,c,c,'m/s' geos5_grided.nc
    ncatted -O -a units,V10M,c,c,'m/s' geos5_grided.nc
    ncatted -O -a SOUTH_WEST_CORNER_LAT,global,c,f,1.025 geos5_grided.nc
    ncatted -O -a NORTH_EAST_CORNER_LAT,global,c,f,49.975 geos5_grided.nc
    ncatted -O -a SOUTH_WEST_CORNER_LON,global,c,f,48.025 geos5_grided.nc
    ncatted -O -a NORTH_EAST_CORNER_LON,global,c,f,122.975 geos5_grided.nc
    ncatted -O -a missing_value,,c,f,-9999 geos5_grided.nc
    ncatted -O -a zenith_interp,global,c,c,'true,false,' geos5_grided.nc
    
    echo "  Merging pre ens$n"
    ncatted -O -a units,PRECTOT,c,c,"kg/m^2/s" PRECTOT_grided.nc
    ncatted -O -a SOUTH_WEST_CORNER_LAT,global,c,f,1.025 PRECTOT_grided.nc
    ncatted -O -a NORTH_EAST_CORNER_LAT,global,c,f,49.975 PRECTOT_grided.nc
    ncatted -O -a SOUTH_WEST_CORNER_LON,global,c,f,48.025 PRECTOT_grided.nc
    ncatted -O -a NORTH_EAST_CORNER_LON,global,c,f,122.975 PRECTOT_grided.nc
    ncatted -O -a missing_value,,c,f,-9999 PRECTOT_grided.nc
#    ncatted -O -a Conventions,,c,c,"CF-1.6" PRECTOT_grided.nc
    ncatted -O -a zenith_interp,global,c,c,'true,false,' PRECTOT_grided.nc

    echo "  renaming ens$n"
    ncrename -v lat,latitude -v lon,longitude  -d lat,latitude -d lon,longitude geos5_grided.nc

    echo "  attr ens$n"
    ncatted -a MAP_PROJECTION,global,c,c,"EQUIDISTANT CYLINDRICAL" -a DX,global,c,f,0.125 -a DY,global,c,f,0.125 geos5_grided.nc 

    echo "  renaming pre ens$n"
    ncrename -d lat,latitude -d lon,longitude -v lat,latitude -v lon,longitude PRECTOT_grided.nc
    echo "  attr pre ens$n"
    ncatted -a MAP_PROJECTION,global,c,c,"EQUIDISTANT CYLINDRICAL" -a DX,global,c,f,0.05 -a DY,global,c,f,0.05 PRECTOT_grided.nc

    cd $GEOS/middle/ens$n
    mkdir -p $GEOS/ens$n
    echo "  spliting ens$n"
    cdo -L -s -O -f nc4 splityearmon geos5_grided.nc $GEOS/ens$n/GEOS5. 
    cdo -L -s -O -f nc4 splityearmon PRECTOT_grided.nc $GEOS/ens$n/PRECTOT. 
    rm geos5_grided.nc PRECTOT_grided.nc
    
    cd $GEOS/ens$n/
    for file in `ls -1 *.nc`; do
        mv $file ${file}4
    done


