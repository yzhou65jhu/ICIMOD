#!/bin/sh

#SBATCH --job-name=extract
#SBATCH --output=./logs/extract.log
#SBATCH --error=./logs/extract.err
#SBATCH --time=12:00:00
#SBATCH --account s1525
#SBATCH --ntasks=28
#SBATCH --mail-user=yzhou65@jhu.edu
#SBATCH --mail-type=ALL

export WORKING=/discover/nobackup/projects/grace/
export LISRUN=$WORKING/Yifan/LISRUN/
export HINDCAST=$LISRUN/SALDAS/Forecast/hindcast_v2/
export CLIM=$HINDCAST/hindcast_CLIM/
export SC=/home/yzhou9/Scripts/SAForecast/Post_LIS_CLIM/Forecast_sepens_v2/

#export CLIM=$WORKING/data/SAForecast/Forecast_CLIM_seperate_ens/

ulimit -v unlimited

mmmdd=oct28

module purge
module load other/cdo
#module load other/nco-4.6.8-gcc-5.3-sp3
mkdir -p $CLIM/middle/alltime

#ms=( 5 6 7 8 9 10 11 )
ms=( 11 12 1 2 3 4 5 6 7 )

vars=( Tair_f_tavg Rainf_f_tavg Evap_tavg TWS_inst Snowcover_inst Tair_f_tavg_min Tair_f_tavg_max )

for yyyy in `seq 2000 2016`; do
    for m in "${ms[@]}"; do
        mm=`printf %02d $m`
        echo "Processing month $yyyy $mm"

        SURF=$HINDCAST/$yyyy/$mmmdd/Noah3.6MP_ensemble/SURFACEMODEL/$yyyy$mm

        cd $SURF

        for file in `ls -1 LIS_HIST_$yyyy${mm}??????.d01.nc`; do
            mmdd=`echo $file | cut -b14-17`
            {
                for var in ${vars[@]}; do
                   cdo -s -L select,name=$var $file $CLIM/middle/alltime/${var}_$yyyy$mmdd.nc
                done
                echo "Var $yyyy$mmdd done.."
            }&
#            ncwa -a ensemble $file $CLIM/alltime/$yyyy$mmdd.nc &
            sleep 0.1s
        done
    done
done

module purge
module load other/nco-4.6.8-gcc-5.3-sp3

for yyyy in `seq 2000 2016`; do
    for m in "${ms[@]}"; do
        mm=`printf %02d $m`
        echo "Processing month $yyyy $mm SM"
        
        SURF=$HINDCAST/$yyyy/$mmmdd/Noah3.6MP_ensemble/SURFACEMODEL/$yyyy$mm
       
        cd $SURF
       
        for file in `ls -1 LIS_HIST_$yyyy${mm}??????.d01.nc`; do
            mmdd=`echo $file | cut -b14-17`
            {
                cd $SURF
                echo "SoilMoist_inst $yyyy$mmdd begin"
                ncks -v SoilMoist_inst $file -O $CLIM/middle/alltime/SM_$yyyy$mmdd.nc
                cd $CLIM/middle/alltime/
                ncks -A $SC/weights.nc SM_$yyyy$mmdd.nc
                ncwa -a SoilMoist_profiles -d SoilMoist_profiles,0,2 -w SoilDepth -v SoilMoist_inst SM_$yyyy$mmdd.nc -O SoilMoist_inst_$yyyy$mmdd.nc
                echo "SoilMoist $yyyy$mmdd done.."
            }& 
            sleep 2s
           #            ncwa -a ensemble $file $CLIM/alltime/$yyyy$mmdd.nc &
        done
    done
done

wait
