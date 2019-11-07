#!/bin/sh

export LISRUN=/discover/nobackup/projects/grace/Yifan/LISRUN/SALDAS/Forecast/hindcast_v2/
export SCRIPTS=/home/yzhou9/Scripts/SAForecast/hindcast_allyear_v2/template/

mmmdd=oct28
for yyyy in `seq 2017 2017`; do
#    rm $LISRUN/$yyyy/may01/5.a.3.SearchModify_OL.sh
    cp $SCRIPTS/5.a.3.SearchModify_OL.sh $LISRUN/$yyyy/$mmmdd/5.a.3.SearchModify_OL.sh
    cp $SCRIPTS/5.a.2.run_SP_auto.sh $LISRUN/$yyyy/$mmmdd/5.a.2.run_SP_auto.sh
    cd $LISRUN/$yyyy/$mmmdd
    sed -i "/^#SBATCH --job-name=/c\#SBATCH --job-name=$yyyy" 5.a.3.SearchModify_OL.sh
    sh 5.a.2.run_SP_auto.sh
done


