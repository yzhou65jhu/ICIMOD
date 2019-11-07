#!/bin/sh
#!/bin/sh
export LISRUN=/discover/nobackup/projects/grace/Yifan/LISRUN/SALDAS/Forecast/hindcast_v2/
export FORCING=/discover/nobackup/projects/grace/data/SAForecast/GEOS5_downscaled/hindcast_v2/
mmmdd=oct28

for yyyy in `seq 2000 2016`; do
    cd $LISRUN/$yyyy/oct28/Noah3.6MP_ensemble/SURFACEMODEL/
    n=`ls -1d 20* | wc -l`
    if [ $n -lt 5 ];
    then
        echo "fixing $yyyy"
        cd $LISRUN/$yyyy/oct28/
        cp lis.config.noahmp.ensemble lis.config.noahmp.ensemble.${yyyy}11
        sed -i "/^[^#]/s/\(Starting year:\).*/\1                             $yyyy/" lis.config.noahmp.ensemble.${yyyy}11
        sed -i "/^[^#]/s/\(Starting month:\).*/\1                            11/" lis.config.noahmp.ensemble.${yyyy}11
        sed -i "/^[^#]/s/\(Starting day:\).*/\1                              29/" lis.config.noahmp.ensemble.${yyyy}11
        sed -i "/^[^#]/s/\(Ending year:\).*/\1                             2200/" lis.config.noahmp.ensemble.${yyyy}11
        sed -i "/^[^#]/s/\(Ending month:\).*/\1                              11/" lis.config.noahmp.ensemble.${yyyy}11
        sed -i "/^[^#]/s/\(Ending day:\).*/\1                                29/" lis.config.noahmp.ensemble.${yyyy}11
        sed -i "/^[^#]/s/\(Noah-MP.3.6 restart file: \).*/\1                  .\/Noah3.6MP_ensemble\/SURFACEMODEL\/${yyyy}11\/LIS_RST_NOAHMP36_${yyyy}11290000.d01.nc/" lis.config.noahmp.ensemble.${yyyy}11
        cp run_LIS_ensemble.sh run_LIS_ensemble.${yyyy}11.sh
        sed -i "s/^\(#SBATCH --time\).*/\1=3:30:00/" run_LIS_ensemble.${yyyy}11.sh
       sed -i "s/mpirun.*/mpirun -np 140 .\/LIS_sep23 -f lis.config.noahmp.ensemble.${yyyy}11/g"  run_LIS_ensemble.${yyyy}11.sh
       sed -i "s/^\(#SBATCH --job-name=\).*/\1f${yyyy}/" run_LIS_ensemble.${yyyy}11.sh
        sbatch run_LIS_ensemble.${yyyy}11.sh

    fi
done
