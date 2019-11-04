#!/bin/bash
export NOAHMP=/home/kshakya/data1/LISRUN/Retro_NoahMP_GDAS_CHIRP[S]/
export SC=/home/kshakya/data1/SCRIPTS/Retro_NoahMP_5km/

cd $NOAHMP/ori
mkdir -p $NOAHMP/dekad

for yyyymm in `ls -1d 20???? | tail -n 3`; do
    ldom=`cal $(date -d "20190901" +"%m %Y") | awk 'NF {DAYS = $NF}; END {print DAYS}'`
    fdds=( 01 11 21 )
    ldds=( 10 20 $ldom )
    echo "$yyyymm dealing with"
    cd $NOAHMP/ori/$yyyymm
    yyyy=`echo $yyyymm | cut -b1-4`
    mm=`echo $yyyymm | cut -b5-6`

    for i in `seq 0 2`; do
        fd=${fdds[$i]}
        ld=${ldds[$i]}
	echo "$i"
        files=`eval ls -1 LIS_HIST_{$yyyymm$fd..$yyyymm$ld}0000.d01.nc`
        if [ $? -eq 0 ]; then
            echo $fd
            ncea $files -O all.${yyyymm}$fd.nc
	    cdo -s -L setgrid,$SC/5kmgrid -settaxis,${yyyy}-${mm}-$fd,00:00:00 -setreftime,${yyyy}-${mm}-$fd,00:00:00 all.${yyyymm}$fd.nc $NOAHMP/dekad/Retro.${yyyymm}$fd.nc
            rm all.${yyyymm}$fd.nc
	fi
    done
#    echo "1"
#    files=`ls LIS_HIST_${yyyymm}0{1..9}0000.d01.nc`
#    ncea $files LIS_HIST_${yyyymm}100000.d01.nc -O all.${yyyymm}01.nc
#    cdo -s -L setgrid,$SC/5kmgrid -settaxis,${yyyy}-${mm}-01,00:00:00 -setreftime,${yyyy}-${mm}-01,00:00:00 all.${yyyymm}01.nc $NOAHMP/dekad/Retro.${yyyymm}01.nc
#    echo "11"
#    ncea LIS_HIST_${yyyymm}{11..20}0000.d01.nc -O all.${yyyymm}11.nc
#    cdo -s -L setgrid,$SC/5kmgrid -settaxis,${yyyy}-${mm}-11,00:00:00 -setreftime,${yyyy}-${mm}-11,00:00:00 all.${yyyymm}11.nc $NOAHMP/dekad/Retro.${yyyymm}11.nc
#    echo "21"
#    files=`ls LIS_HIST_${yyyymm}{21..31}0000.d01.nc`
#    ncea $files -O all.${yyyymm}21.nc
#    cdo -s -L setgrid,$SC/5kmgrid -settaxis,${yyyy}-${mm}-21,00:00:00 -setreftime,${yyyy}-${mm}-21,00:00:00 all.${yyyymm}21.nc $NOAHMP/dekad/Retro.${yyyymm}21.nc
#    rm all.${yyyymm}?1.nc
    
    cd $NOAHMP/dekad/
    for file in `ls -1 Retro.${yyyymm}?1.nc`; do
        echo "changing units for $file"
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
done

#See /home/kshakya/data1/LISRUN/Retro_NoahMP_GDAS_Chirps/NoahMP/monthly/fix.sh
