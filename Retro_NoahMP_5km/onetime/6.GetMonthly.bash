#!/bin/bash
export NOAHMP=/home/kshakya/data1/LISRUN/Retro_NoahMP_GDAS_Chirps/NoahMP/
export SC=//home/kshakya/data1/SCRIPTS/Retro_NoahMP_5km/

cd $NOAHMP/SURFACEMODEL/
mkdir -p $NOAHMP/monthly
for yyyymm in `ls -1d 20????`; do
#yyyymm=200001
    echo $yyyymm
    cd $NOAHMP/SURFACEMODEL/$yyyymm
    echo "$yyyymm"
    yyyy=`echo $yyyymm | cut -b1-4`
    mm=`echo $yyyymm | cut -b5-6`
    ncea LIS_HIST*.d01.nc -O all.${yyyymm}.nc 
    cdo -s -L setgrid,$SC/5kmgrid -settaxis,${yyyy}-${mm}-01,00:00:00 -setreftime,${yyyy}-${mm}-01,00:00:00 all.${yyyymm}.nc $NOAHMP/monthly/Retro.${yyyymm}.nc
    rm all.${yyyymm}.nc
done

#See /home/kshakya/data1/LISRUN/Retro_NoahMP_GDAS_Chirps/NoahMP/monthly/fix.sh
