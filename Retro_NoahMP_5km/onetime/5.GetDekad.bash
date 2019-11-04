#!/bin/bash
export NOAHMP=/home/kshakya/data1/LISRUN/Retro_NoahMP_GDAS_Chirps/NoahMP/

cd $NOAHMP/SURFACEMODEL/
mkdir -p $NOAHMP/dekad
for yyyymm in `ls -1d 20????`; do
#yyyymm=200001
    echo $yyyymm
    cd $NOAHMP/SURFACEMODEL/$yyyymm
    yyyy=`echo $yyyymm | cut -b1-4`
    mm=`echo $yyyymm | cut -b5-6`
    echo "1"
#    f=`ls -1 LIS_HIST*.nc | head -n 1 | cut -b17`
    files=`ls LIS_HIST_${yyyymm}0{1..9}0000.d01.nc`
#    ncea LIS_HIST_${yyyymm}0{$f..9}0000.d01.nc LIS_HIST_${yyyymm}100000.d01.nc -O $NOAHMP/dekad/Retro.${yyyymm}01.nc
    ncea $files LIS_HIST_${yyyymm}100000.d01.nc -O all.${yyyymm}01.nc
    cdo -s -L setgrid,$SC/5kmgrid -settaxis,${yyyy}-${mm}-01,00:00:00 -setreftime,${yyyy}-${mm}-01,00:00:00 all.${yyyymm}01.nc $NOAHMP/dekad/Retro.${yyyymm}01.nc
    echo "11"
    ncea LIS_HIST_${yyyymm}{11..20}0000.d01.nc -O all.${yyyymm}11.nc
    cdo -s -L setgrid,$SC/5kmgrid -settaxis,${yyyy}-${mm}-11,00:00:00 -setreftime,${yyyy}-${mm}-11,00:00:00 all.${yyyymm}11.nc $NOAHMP/dekad/Retro.${yyyymm}11.nc
    echo "21"
    files=`ls LIS_HIST_${yyyymm}{21..31}0000.d01.nc`
    ncea $files -O all.${yyyymm}21.nc
    cdo -s -L setgrid,$SC/5kmgrid -settaxis,${yyyy}-${mm}-21,00:00:00 -setreftime,${yyyy}-${mm}-21,00:00:00 all.${yyyymm}21.nc $NOAHMP/dekad/Retro.${yyyymm}21.nc
    rm all.${yyyymm}?1.nc
done

#See /home/kshakya/data1/LISRUN/Retro_NoahMP_GDAS_Chirps/NoahMP/monthly/fix.sh
