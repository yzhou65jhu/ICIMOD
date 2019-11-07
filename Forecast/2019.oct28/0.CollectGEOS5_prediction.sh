#!/bin/sh

yyyy=2001
mmmdd=oct28

export WORKING=/data1/LISRUN/Forecast/
export GEOS=$WORKING/GEOS5/$yyyy/$mmmdd/

mkdir -p $GEOS/

cd $GEOS/

wget -r -np -nH -N -c --cut-dirs=4 -R "index.html*" https://gis1.servirglobal.net/data/geos_s2s/$yyyy/$mmmdd/


