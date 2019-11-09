#!/bin/sh
#This scripts correct bias and standard deviation of precipitation and convective precipitation using CDF quantile matching method.


#Set forecast initial date. This should be changed for every forecast.
yyyy=2019
mmmdd=oct28

#Set folder paths.
export WORKING=/data1/LISRUN/Forecast/
export GARD_YEAR=$WORKING/GARDRUN/$yyyy/$mmmdd/
export MAPP=$WORKING/quantile/mapping_precp_v2_9month/
export MAPC=$WORKING/quantile/mapping_CRain_v2_9month/

#Set the first date of the forecast data. This will be used to determine the climatology CDF. Climatology CDF are different for each month. 
first_date=`date -d "$mmmdd $yyyy" "+%Y-%m-%d"`

source activate py2k
ulimit -v unlimited

cd $GARD_YEAR

for ens in `ls -1d ens*`; do
    
    {
    echo "CDF matching $ensi precipitation"
    cd $GARD_YEAR/$ens/output

    #Make a copy of precipitation template folder for each ensemble member
    rsync -a $MAPP mapping_precp_v2_9month
    cd mapping_precp_v2_9month
    ln -s ../gard_out_precip.nc .
    sed -i "/first_date=/c\first_date=$first_date" mapping.sh
    echo "mapping $yyyy $mmmdd $ens $i precip"

    #Run python script to perform CDF quantile matching for precipitation 
    python mapping_discover.py $first_date
    mv mapped_out_precip.nc ../

    echo "CDF matching $ensi CRain"
    cd $GARD_YEAR/$ens/output

    #Make a copy of convective precipitation template folder for each ensemble member
    rsync -a $MAPC mapping_CRain_v2_9month
    cd mapping_CRain_v2_9month
    ln -s ../gard_out_CRainf_f_tavg.nc .
    sed -i "/first_date=/c\first_date=$first_date" mapping.sh
    echo "mapping $yyyy $mmmdd $ens $i CRain"

    #Run python script to perform CDF quantile matching for convective rainfall
    python mapping_discover.py $first_date
    mv mapped_out_CRain.nc ../
    } > $GARD_YEAR/$ens/logs/post.log 2> $GARD_YEAR/$ens/logs/post.err &
    sleep 1m
done
