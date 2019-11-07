#!/bin/sh
## Specify a name for the job allocation
#SBATCH --job-name=forecast
## Specify a filename for standard output
#SBATCH --output=forecast.log
## Specify a filename for standard error
#SBATCH --error=forecast.err
## Set a limit on the total run time
#SBATCH --time=12:00:00
## Enter NCCS Project ID below:
#SBATCH --account s1525
## Adjust node, core, and hardware constraints
#SBATCH --nodes=5 --constraint=hasw
## Set number of tasks ~ processes per node
## Set number of cpus (cores) per task (process)
##SBATCH --cpus-per-task=1
# Substitute your e-mail here
#SBATCH --mail-user=yzhou65@jhu.edu
#SBATCH --mail-type=ALL
##SBATCH --qos=long

export WORKING=/discover/nobackup/projects/grace/
export LISRUN=$WORKING/Yifan/LISRUN/SALDAS/
export FORECAST=$LISRUN/Forecast/hindcast_v2/
export RETRO=$LISRUN/Retro_NoahMP_GDAS_Chirps/NoahMP/SURFACEMODEL/
export FORCING=$GRACE/data/SAForecast/GEOS5_downscaled/hindcast_v2/

mkdir -p $FORECAST

mds=( oct28 )


yyyy=2000
mmmdd=oct28
mkdir -p $FORECAST/$yyyy/$mmmdd

nens=`ls -1d $FORCING/$yyyy/$mmmdd/ens* | wc -l`


#for yyyy in `seq 2000 2000`; do
#    for mmmdd in "${mds[@]}"; do
        rsync -a $LISRUN/Forecast/template_v2/ $FORECAST/$yyyy/$mmmdd/

        cd $FORECAST/$yyyy/$mmmdd/RSTFILE
        ### please note first two lines below are different from v1
        lyyyymm=`date -d "$mmmdd $yyyy +1 month" "+%Y%m"`
        yyyymmdd=`date -d "${lyyyymm}01 -1 day" "+%Y%m%d"`
        yyyymm=`echo $yyyymmdd | cut -b1-6`
        ln -sf $RETRO/$yyyymm/LIS_RST_NOAHMP36_${yyyymmdd}2345.d01.nc .

        cd $FORECAST/$yyyy/$mmmdd
        sed -i "s/^\(Input restart filename:\).*/\1        .\/RSTFILE\/LIS_RST_NOAHMP36_${yyyymmdd}2345.d01.nc/" ldt.config.ensemble
        sed -i "s/^\(Output restart filename:\).*/\1        .\/RSTFILE\/LIS_ensrst_NOAHMP36_${yyyymmdd}2345.d01.nc/" ldt.config.ensemble
        sed -i "s/^\(Number of ensembles per tile (output restart):\).*/\1 $nens/" ldt.config.ensemble
        sh run_LDT_ensemble.sh 

        sed -i "s/^\(Noah-MP.3.6 restart file:\).*/\1        .\/RSTFILE\/LIS_ensrst_NOAHMP36_${yyyymmdd}2345.d01.nc/" lis.config.noahmp.ensemble 

        yyyymmdd=`date -d "${yyyymm}01 +1month" "+%Y%m%d"`
        yy=`echo $yyyymmdd | cut -b1-4`
        mm=`echo $yyyymmdd | cut -b5,6`
        dd=`echo $yyyymmdd | cut -b7,8`

        sed -i "s/^\(Starting year:\).*/\1                             $yy/" lis.config.noahmp.ensemble
        sed -i "s/^\(Starting month:\).*/\1                            $mm/" lis.config.noahmp.ensemble
        sed -i "s/^\(Starting day:\).*/\1                              $dd/" lis.config.noahmp.ensemble
        sed -i "s/^\(Number of ensembles per tile:\).*/\1   $nens/" lis.config.noahmp.ensemble
        sed -i "s/^\(Generic ensemble forecast number of ensemble members:\).*/\1     $nens/" lis.config.noahmp.ensemble
        sed -i "s/^\(Precipitation ensemble forecast number of ensemble members:\).*/\1     $nens/" lis.config.noahmp.ensemble

        NYYYY=`date -d "$yy-$mm-01 +1months" "+%Y"`
        NMM=`date -d "$yy-$mm-01 +1months" "+%m"`  
        sed -i "/^[^#]/s/\(Ending year:\).*/\1                               $NYYYY/" lis.config.noahmp.ensemble
        sed -i "/^[^#]/s/\(Ending month:\).*/\1                              $NMM/" lis.config.noahmp.ensemble
        sed -i "/^[^#]/s/\(Ending day:\).*/\1                                01/" lis.config.noahmp.ensemble 

        mkdir -p $FORECAST/$yyyy/$mmmdd/FORCING/$yyyy/$mmmdd/

        cd $FORCING/$yyyy/$mmmdd/

        i=1
        for ens in `ls -1d ens*`; do
            ln -s $FORCING/$yyyy/$mmmdd/$ens/ $FORECAST/$yyyy/$mmmdd/FORCING/$yyyy/$mmmdd/ens$i
            i=$(($i+1))
        done
        

#        ln -sf $FORCING/$yyyy/$mmmdd .
        cd $FORECAST/$yyyy/$mmmdd/FORCING/$yyyy/

        mon=( jan feb mar apr may jun jul aug sep oct nov dec )
        for mmm in "${mon[@]}"; do
            ln -sf $mmmdd ${mmm}01
        done

        cd $FORECAST/$yyyy/$mmmdd/FORCING/
        yyyy1=`date -d "${yyyy}0101 + 1year"  "+%Y"`
        ln -s $yyyy $yyyy1

        cd $FORECAST/$yyyy/$mmmdd/
        sh run_LIS_ensemble.sh

#    done
#done


