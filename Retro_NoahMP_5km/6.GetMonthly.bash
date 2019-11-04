#!/bin/bash
export NOAHMP=/home/kshakya/data1/LISRUN/Retro_NoahMP_GDAS_CHIRP[S]
export SC=/home/kshakya/data1/SCRIPTS/Retro_NoahMP_5km/

cd $NOAHMP/ori/
mkdir -p $NOAHMP/monthly
for yyyymm in `ls -1d 20???? | tail -n 3`; do
#yyyymm=200001
    echo $yyyymm
    cd $NOAHMP/ori/$yyyymm
    echo "$yyyymm"
    yyyy=`echo $yyyymm | cut -b1-4`
    mm=`echo $yyyymm | cut -b5-6`
#    ncea LIS_HIST*.d01.nc -O all.${yyyymm}.nc 
    rm -f all.${yyyymm}.nc alltime.${yyyymm}.nc
    cdo -s -L cat LIS_HIST*.d01.nc alltime.${yyyymm}.nc
    cdo -s -L timavg alltime.${yyyymm}.nc all.${yyyymm}.nc
    rm alltime.${yyyymm}.nc
    cdo -s -L setgrid,$SC/5kmgrid -settaxis,${yyyy}-${mm}-01,00:00:00 -setreftime,${yyyy}-${mm}-01,00:00:00 all.${yyyymm}.nc $NOAHMP/monthly/Retro.${yyyymm}.nc
    rm all.${yyyymm}.nc
    cd $NOAHMP/monthly/
    file=Retro.${yyyymm}.nc
    cp $file $file.mod
    ncks -A $SC/weights.nc $file.mod
    ncwa -a lev_2 -d lev_2,0,2 -w SoilDepth -v SoilMoist_inst $file.mod -O $file.mod
    ncks -x -v SoilMoist_inst $file -O $file
    ncks -x -v lev_2 $file.mod -O $file.mod
    ncks -A $file.mod $file
    rm $file.mod
    ncap2 -s "Evap_tavg=Evap_tavg*86400; Rainf_f_tavg=Rainf_f_tavg*86400; SoilMoist_inst=SoilMoist_inst*1000 " $file -O $file
    ncatted -a units,Rainf_f_tavg,m,c,"mm day-1" -a units,Evap_tavg,m,c,"mm day-1" -a units,SoilMoist_inst,m,c,"kg m2-1" $file 
done

#See /home/kshakya/data1/LISRUN/Retro_NoahMP_GDAS_Chirps/NoahMP/monthly/fix.sh
