#!/bin/bash
export NOAHMP=/home/kshakya/data1/LISRUN/Retro_NoahMP_GDAS_Chirps/NoahMP/
export SC=//home/kshakya/data1/SCRIPTS/Retro_NoahMP_5km/

cd $NOAHMP/SURFACEMODEL/
mkdir -p $NOAHMP/3monthly/middle
for yyyy in `seq 2000 2019`; do
    for m in `seq 1 12`; do
        rm -f $NOAHMP/3monthly/middle/*
        sm=`printf "%02d" $m`
        for dm in `seq 0 2`; do
            yyyymm=`date -d "${yyyy}-${sm}-01 +${dm}month" "+%Y%m"`
            cd $NOAHMP/3monthly/middle/
            ln -sf $NOAHMP/SURFACEMODEL/$yyyymm/LIS_HIST*.nc .
            echo $yyyymm
        done
        sm1=`printf "%02d" $(($m + 1))`
        sm2=`printf "%02d" $(($m + 2))`
        ncea LIS_HIST*.nc all.$yyyy$sm$sm1$sm2.nc 
	cdo -s -L setgrid,$SC/5kmgrid -settaxis,${yyyy}-${sm}-01,00:00:00 -setreftime,${yyyy}-${sm}-01,00:00:00 all.$yyyy$sm$sm1$sm2.nc ../Retro.$yyyy$sm$sm1$sm2.nc
        rm all.$yyyy$sm$sm1$sm2.nc
    done
done


#See /home/kshakya/data1/LISRUN/Retro_NoahMP_GDAS_Chirps/NoahMP/monthly/fix.sh
