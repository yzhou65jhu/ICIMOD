#!/bin/sh
export GEOS5PATH=/discover/nobackup/projects/gmao/m2oasf/aogcm/g5fcst/forecast/production/geos-s2s/runx/
export SAFORECAST=/discover/nobackup/projects/grace/data/SAForecast/GEOS5_for_downscale/hindcast_allyear/

#monthNames=( apr26 )
monthNames=( oct28 )

geos5VariableNames=( PRECTOT CNPRCP T2M Q2M PS SLRSF LWS U10M V10M )
varnames=`IFS=, ; echo "${geos5VariableNames[*]}"`

module purge
module load other/cdo

for yyyy in `seq 2000 2019`; do
    for mmmdd in "${monthNames[@]}"; do
        echo "$yyyy, $mmmdd"
        #create folder for yyyy, mmmdd
        ALLTIME=$SAFORECAST/$yyyy/$mmmdd
        mkdir -p $ALLTIME

        echo -n "$yyyy, $mmmdd: ">> $SAFORECAST/filecounts.txt

        #Copying 
        cd $GEOS5PATH/$yyyy/$mmmdd
        for ensi in `ls -d ens*`; do
            {
             
            mkdir -p $ALLTIME/$ensi
            cd $GEOS5PATH/$yyyy/$mmmdd/$ensi

            if [ -d geosgcm_vis2d ]; then
                echo "  copying $yyyy, $mmmdd: $ensi-->normal"
                cd geosgcm_vis2d
                for name in `ls -1 *.tar`; do
                    #echo "    extracting $name"
                    #printf "\n"
                    tar -xf $name -C $ALLTIME/$ensi/
                done
            else
                if [ -d holding/geosgcm_vis2d/ ]; then
                    echo "  copying $yyyy, $mmmdd: $ensi-->holding"
                    cd holding/geosgcm_vis2d/
                    name=`ls -1 *.tar`
                    #echo "      extracting $name"
                    #printf "\n"
                    tar -xf $name -C $ALLTIME/$ensi/
                else
                    echo "  $year, $month:no folder!! check it!"
                fi
            fi

            cd $ALLTIME/$ensi/
            nof=`ls -1 *.nc4| wc -l`
            echo "$yyyy, $mmmdd, $ensi ($nof) " >> $SAFORECAST/filecounts.txt

#            echo "  subsetting and combining useful variables into one file"
            mkdir -p $ALLTIME/$ensi/onefile
            echo "combining all timesteps into one file $yyyy $mmmdd $ensi"
            rm -f onefile/geos.$yyyy.$mmmdd.$ensi.allvariable.nc
            cdo -L -s mergetime *.nc4 onefile/geos.$yyyy.$mmmdd.$ensi.allvariable.nc
            cd onefile
#            echo "    subsetting useful variables into one file"
            cdo -L -s select,name=$varnames geos.$yyyy.$mmmdd.$ensi.allvariable.nc geos.$yyyy.$mmmdd.$ensi.nc
            rm geos.$yyyy.$mmmdd.$ensi.allvariable.nc
            echo "$yyyy $mmmdd $ensi done"
            }&
            sleep 10s
        done
        wait 
        echo "" >> $SAFORECAST/filecounts.txt
    done
done



