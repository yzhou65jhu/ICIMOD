#!/bin/sh
export LISRUN=/discover/nobackup/projects/grace/Yifan/LISRUN/SALDAS/Forecast/hindcast_v2/

for yyyy in `seq 2002 2016`; do
    cd $LISRUN/$yyyy/oct28/Noah3.6MP_ensemble/SURFACEMODEL/
    n=`ls -1d 20* | wc -l`
    if [ $n -lt 5 ]; 
    then
        echo "$yyyy bad"
        cd $LISRUN/$yyyy/oct28/
        cp /discover/nobackup/projects/grace/Yifan/LISRUN/SALDAS/Forecast/hindcast_v2/2001/oct28/lis.config.noahmp.ensemble.fix .
        cp /discover/nobackup/projects/grace/Yifan/LISRUN/SALDAS/Forecast/hindcast_v2/2001/oct28/run_LIS_ensemble.fix.sh . 
        sed -i "/^[^#]/s/\(Starting year:\).*/\1                             $yyyy/" lis.config.noahmp.ensemble.fix 
        sed -i "/^[^#]/s/\(Ending year:\).*/\1                               $yyyy/" lis.config.noahmp.ensemble.fix
        sed -i "/^[^#]/s/\(Ending month:\).*/\1                              11/" lis.config.noahmp.ensemble.fix 
        sed -i "/^[^#]/s/\(Ending day:\).*/\1                                28/" lis.config.noahmp.ensemble.fix 
        sed -i "/^[^#]/s/\(Noah-MP.3.6 restart file: \).*/\1                  .\/RSTFILE\/LIS_ensrst_NOAHMP36_${yyyy}10312345.d01.nc/" lis.config.noahmp.ensemble.fix
        echo "running $yyyy lis"
        sh run_LIS_ensemble.fix.sh
        echo "$yyyy lis done"
    else 
        echo "$yyyy good"
    fi
done
