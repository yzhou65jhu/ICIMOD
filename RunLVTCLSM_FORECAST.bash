#!/bin/bash

source ~/.bashrc

PROJECT=~/data1/FORECAST/
CONFIG=LVT_DI/configs
SCRIPTS=/data1/SCRIPTS/

LOGS=/home/kshakya/data1/SCRIPTS/logs/LVT_logs/

CONFIG_SF=lvt.config_forecast_perc_sf
CONFIG_RTZ=lvt.config_forecast_perc_rtz
CONFIG_TWS=lvt.config_forecast_perc_tws

# Locate the latest forecast output (ensemble mean)

cd $PROJECT/SAForecast_CLSM
OUTPUTFOLDER=$(ls -1 | grep -e CLSM_EN_ | sort | tail -1)

# Enter the output folder and locate the first and the last folder

cd $PROJECT/SAForecast_CLSM/$OUTPUTFOLDER/SURFACEMODEL

STARTF=$(ls -1 | sort | head -1)
ENDF=$(ls -1 | sort | tail -1)

# Extract the start and end date of the forecast output

cd $PROJECT/SAForecast_CLSM/$OUTPUTFOLDER/SURFACEMODEL/$STARTF

STARTD=$(ls -1 | grep -e LIS_HIST | head -1)
STARTYYYY=$(echo $STARTD | cut -b 10-13)
STARTMM=$(echo $STARTD | cut -b 14-15)
STARTDD=$(echo $STARTD | cut -b 16-17)

file=$LOGS/LVT_${STARTYYYY}${STARTMM}.log

cd $PROJECT/SAForecast_CLSM/$OUTPUTFOLDER/SURFACEMODEL/$ENDF

ENDD=$(ls -1 | grep -e LIS_HIST | tail -n 2 | head -n 1)
ENDYYYY=$(echo $ENDD | cut -b 10-13)
ENDMM=$(echo $ENDD | cut -b 14-15)
ENDDD=$(echo $ENDD | cut -b 16-17)


# modify the corresponding lvt.config
# note that the climatology of percentile has already been created based on daily output from 2000.1.1 to 2017.12.31, so that 
# here we only run lvt.config in a "restart" mode to generate the percentile for the forecast data in order to save conputational time
# The strategy could be improved later on.

# Update LVT configure file
echo "updating LVT configure file"  >> $file

cd $PROJECT$CONFIG

# update lvt config for surface soil moisture

sed -i "/^\s*Starting year/c\Starting year:                             $STARTYYYY" $CONFIG_SF
sed -i "/^\s*Starting month/c\Starting month:                            $STARTMM" $CONFIG_SF
sed -i "/^\s*Starting day/c\Starting day:                              $STARTDD" $CONFIG_SF

sed -i "/^\s*Ending year/c\Ending year:                               $ENDYYYY" $CONFIG_SF
sed -i "/^\s*Ending month/c\Ending month:                              $ENDMM" $CONFIG_SF
sed -i "/^\s*Ending day/c\Ending day:                                $ENDDD" $CONFIG_SF
sed -i "/^\s*Metrics output frequency/c\Metrics output frequency:                       1da" $CONFIG_SF

sed -i "/^\s*LIS output directory/c\LIS output directory:               ..\/..\/SAForecast_CLSM\/$OUTPUTFOLDER  " $CONFIG_SF

# update lvt config for rootzone soil moisture

sed -i "/^\s*Starting year/c\Starting year:                             $STARTYYYY" $CONFIG_RTZ
sed -i "/^\s*Starting month/c\Starting month:                            $STARTMM" $CONFIG_RTZ
sed -i "/^\s*Starting day/c\Starting day:                              $STARTDD" $CONFIG_RTZ

sed -i "/^\s*Ending year/c\Ending year:                               $ENDYYYY" $CONFIG_RTZ
sed -i "/^\s*Ending month/c\Ending month:                              $ENDMM" $CONFIG_RTZ
sed -i "/^\s*Ending day/c\Ending day:                                $ENDDD" $CONFIG_RTZ
sed -i "/^\s*Metrics output frequency/c\Metrics output frequency:                       1da" $CONFIG_RTZ

sed -i "/^\s*LIS output directory/c\LIS output directory:               ..\/..\/SAForecast_CLSM\/$OUTPUTFOLDER  " $CONFIG_RTZ

# update lvt config for terrestrial water storage

sed -i "/^\s*Starting year/c\Starting year:                             $STARTYYYY" $CONFIG_TWS
sed -i "/^\s*Starting month/c\Starting month:                            $STARTMM" $CONFIG_TWS
sed -i "/^\s*Starting day/c\Starting day:                              $STARTDD" $CONFIG_TWS

sed -i "/^\s*Ending year/c\Ending year:                               $ENDYYYY" $CONFIG_TWS
sed -i "/^\s*Ending month/c\Ending month:                              $ENDMM" $CONFIG_TWS
sed -i "/^\s*Ending day/c\Ending day:                                $ENDDD" $CONFIG_TWS
sed -i "/^\s*Metrics output frequency/c\Metrics output frequency:                       1da" $CONFIG_TWS

sed -i "/^\s*LIS output directory/c\LIS output directory:               ..\/..\/SAForecast_CLSM\/$OUTPUTFOLDER  " $CONFIG_TWS



echo "$STARTYYYY$STARTMM$STARTDD"
echo "$ENDYYYY$ENDMM$ENDDD"

if [ "$STARTYYYY$STARTMM$STARTDD" -lt "$ENDYYYY$ENDMM$ENDDD" ]; then
        echo "Running LVT..." >> $file
         ./LVT $CONFIG_SF >> $file                                            
         ./LVT $CONFIG_RTZ >> $file
         ./LVT $CONFIG_TWS >> $file      

        echo "done." >> $file
fi




