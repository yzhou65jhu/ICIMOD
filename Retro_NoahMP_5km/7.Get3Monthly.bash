#!/bin/bash
export NOAHMP=/home/kshakya/data1/LISRUN/Retro_NoahMP_GDAS_CHIRP[S]
export SC=/home/kshakya/data1/SCRIPTS/Retro_NoahMP_5km/

cd $NOAHMP/ori/
mkdir -p $NOAHMP/3monthly/middle
#for yyyy in `seq 2000 2019`; do
#    for m in `seq 1 12`; do
for lastyyyymm in `ls -1d 20???? | tail -n 3`; do
    echo "dealing with last month ->$lastyyyymm"
    firstyyyymm=`date -d "${lastyyyymm}01 -2month" "+%Y%m"`
    yyyy=`echo $firstyyyymm | cut -b1-4`
    sm=`echo $firstyyyymm | cut -b5-6`
    rm -f $NOAHMP/3monthly/middle/*
    for dm in `seq 0 2`; do
        yyyymm=`date -d "${yyyy}-${sm}-01 +${dm}month" "+%Y%m"`
        cd $NOAHMP/ori/$yyyymm/
        for file in `ls -1 LIS_HIST*.nc`; do
            ln -sf $NOAHMP/ori/$yyyymm/$file $NOAHMP/3monthly/middle/
        done
        echo $yyyymm
    done
    sm1=`printf "%02d" $(($sm + 1))`
    sm2=`printf "%02d" $(($sm + 2))`
    cd $NOAHMP/3monthly/middle/
    rm -f alltime.$yyyy$sm$sm1$sm2.nc all.$yyyy$sm$sm1$sm2.nc
    echo "  calculating average $sm$sm1$sm2"
    cdo -L -s cat LIS_HIST*.nc alltime.$yyyy$sm$sm1$sm2.nc
    cdo -L -s timavg alltime.$yyyy$sm$sm1$sm2.nc all.$yyyy$sm$sm1$sm2.nc 
    rm alltime.$yyyy$sm$sm1$sm2.nc
    cdo -s -L setgrid,$SC/5kmgrid -settaxis,${yyyy}-${sm}-01,00:00:00 -setreftime,${yyyy}-${sm}-01,00:00:00 all.$yyyy$sm$sm1$sm2.nc ../Retro.$yyyy$sm$sm1$sm2.nc
    rm all.$yyyy$sm$sm1$sm2.nc
    
    cd $NOAHMP/3monthly/
    echo "  Changing units $sm$sm1$sm2"
    file=Retro.$yyyy$sm$sm1$sm2.nc
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
