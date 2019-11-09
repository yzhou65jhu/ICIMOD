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
export HINDCAST=$LISRUN/SALDAS/Forecast/hindcast_v1/
export CLIM=$HINDCAST/hindcast_CLIM/
export SC=/home/yzhou9/Scripts/SAForecast/Post_LIS_CLIM/Forecast_sepens/

#export CLIM=$WORKING/data/SAForecast/Forecast_CLIM_seperate_ens/

ulimit -v unlimited

mmmdd=may01

module purge
module load other/cdo
mkdir -p $CLIM/middle/alltime

ms=( 5 )

vars=( Tair_f_tavg )
var=Tair_f_tavg

mkdir -p $CLIM

for yyyy in `seq 2000 2017`; do
    for m in "${ms[@]}"; do
        mm=`printf %02d $m`
        echo "Processing month $yyyy $mm"

        SURF=$HINDCAST/$yyyy/$mmmdd/Noah3.6MP_ensemble/SURFACEMODEL/$yyyy$mm

        cd $SURF

        for file in `ls -1 LIS_HIST_$yyyy${mm}??????.d01.nc`; do
            mmdd=`echo $file | cut -b14-17`
            {
#                for var in ${vars[@]}; do
                    module purge
                    module load other/cdo
                    cd $SURF
                    cdo -s -L select,name=$var $file $CLIM/middle/alltime/${var}_$yyyy$mmdd.nc
                    module purge
                    module load other/nco-4.6.8-gcc-5.3-sp3
                    cd $CLIM/middle/alltime/
                    ncwa -a ensemble ${var}_$yyyy$mmdd.nc -O ${var}_$yyyy$mmdd.ensmean.nc 
                    rm ${var}_$yyyy$mmdd.nc
#                done
                echo "Var $yyyy$mmdd done.."
            }&
#            ncwa -a ensemble $file $CLIM/alltime/$yyyy$mmdd.nc &
            sleep 0.05s
        done
    done
    wait
    module purge
    module load other/nco-4.6.8-gcc-5.3-sp3
    cd $CLIM/middle/alltime/
    ncecat -h ${var}_${yyyy}????.ensmean.nc -O $var.$yyyy$mm.daily.alltime.nc
    ncwa -h -a record $var.$yyyy$mm.daily.alltime.nc $var.$yyyy$mm.ensmean.nc
    rm $var.$yyyy$mm.daily.alltime.nc
done
cd $CLIM/middle/alltime/
module purge
module load other/nco-4.6.8-gcc-5.3-sp3
ncecat -h ${var}.20????.ensmean.nc -O $var.$mm.alltime.nc

