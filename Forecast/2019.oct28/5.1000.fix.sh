#!/bin/sh
#!/bin/sh
export LISRUN=/discover/nobackup/projects/grace/Yifan/LISRUN/SALDAS/Forecast/hindcast_v2/
export FORCING=/discover/nobackup/projects/grace/data/SAForecast/GEOS5_downscaled/hindcast_v2/
mmmdd=oct28

for yyyy in `seq 2000 2009`; do
    cd $LISRUN/$yyyy/oct28/Noah3.6MP_ensemble/SURFACEMODEL/
    n=`ls -1d 20* | wc -l`
    if [ $n -lt 5 ];
    then
        echo "fixing $yyyy"
        cd $FORCING/$yyyy/$mmmdd        
        for ens in `ls -1d ens*`; do
            cd $FORCING/$yyyy/$mmmdd/$ens/
#            cp GEOS5.${yyyy}11.nc4 GEOS5.${yyyy}11.nc4.ori
#            cp GEOS5.${yyyy}12.nc4 GEOS5.${yyyy}11.nc4
        done
        cd $LISRUN/$yyyy/oct28/
        cp lis.config.noahmp.ensemble lis.config.noahmp.ensemble.fix2
        sed -i "/^[^#]/s/\(Starting year:\).*/\1                             $yyyy/" lis.config.noahmp.ensemble.fix2
        sed -i "/^[^#]/s/\(Starting month:\).*/\1                            11/" lis.config.noahmp.ensemble.fix2
        sed -i "/^[^#]/s/\(Starting day:\).*/\1                              28/" lis.config.noahmp.ensemble.fix2
        sed -i "/^[^#]/s/\(Ending year:\).*/\1                             $yyyy/" lis.config.noahmp.ensemble.fix2
        sed -i "/^[^#]/s/\(Ending month:\).*/\1                            11/" lis.config.noahmp.ensemble.fix2
        sed -i "/^[^#]/s/\(Ending day:\).*/\1                              29/" lis.config.noahmp.ensemble.fix2
        sed -i "/^[^#]/s/\(Noah-MP.3.6 restart file: \).*/\1                  .\/Noah3.6MP_ensemble\/SURFACEMODEL\/${yyyy}11\/LIS_RST_NOAHMP36_${yyyy}11280000.d01.nc/" lis.config.noahmp.ensemble.fix2
        ulimit -s unlimited
        module purge
        source ~/Scripts/setenv_wanshu.sh
        mpirun -np 28 ./LIS_sep23 -f lis.config.noahmp.ensemble.fix2

        cd $FORCING/$yyyy/$mmmdd
        for ens in `ls -1d ens*`; do
            cd $FORCING/$yyyy/$mmmdd/$ens/
            cp GEOS5.${yyyy}11.nc4.ori GEOS5.${yyyy}11.nc4
        done
    fi
done
