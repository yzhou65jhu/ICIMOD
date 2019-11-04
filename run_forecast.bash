#!bin/bash
#Author: Yifan Zhou (yzhou65@jhu.edu)


echo "This scripts run the CLSM forecast"
export ROOT=/home/kshakya/
export SCRIPT=${ROOT}/data1/SCRIPTS
export FORECAST=${ROOT}/data1/FORECAST
export LOGS=${SCRIPT}/data1/logs/forecast_CLSM_logs

echo "source $ROOT.bashrc"
source ${ROOT}.bashrc

cd ${FORECAST}/SAForecast_CLSM/FORCING

yyyy=`ls -1 | tail -n 1`

cd $yyyy

mmmdd=`ls -1 | sort -M | tail -n 1`
mmm=`echo $mmmdd | cut -c1-3`
dd=`echo $mmmdd | cut -c4-5`
mm=`date -d "$mmm 1 $yyyy" "+%m"`

last_mm=`date -d "$mmm 1 $yyyy -1 month" "+%m"`
last_yyyy=`date -d "$mmm 1 $yyyy -1 month" "+%Y"`
last_mm_max_day=`cal $last_mm $last_yyyy | awk 'NF {DAYS = $NF}; END {print DAYS}'`

RSTFILE=$FORECAST/CLSM_Retro/output/OL_big_v2/SURFACEMODEL/$last_yyyy$last_mm/LIS_RST_CLSMF25_${last_yyyy}${last_mm}${last_mm_max_day}2330.d01.nc

if [ ! -f $RSTFILE ]; then
    echo "  Restart file $RSTFILE does not exist! Check your CLSM retrospective run!"
    exit 1
fi

cp $RSTFILE $FORECAST/SAForecast_CLSM/RSTFILE

cd $FORECAST/SAForecast_CLSM

echo "  Updating LDT configure..."
sed -i "/^\s*Input restart filename/c\Input restart filename:     .\/RSTFILE\/LIS_RST_CLSMF25_${last_yyyy}${last_mm}${last_mm_max_day}2330.d01.nc" ldt.config.ensemble
sed -i "/^\s*Output restart filename/c\Output restart filename:     .\/RSTFILE\/LIS_enRST_${last_yyyy}${last_mm}${last_mm_max_day}2330.d01.nc" ldt.config.ensemble
sed -i "/^\s*LDT diagnostic file/c\LDT diagnostic file:     .\/logs\/$yyyy$mm\/ldtlog" ldt.config.ensemble

echo "  Begin to run LDT" `date`
#bash RunLDT.sh
echo "  LDT end at " `date`


echo "  checking $FORECAST/SAForecast_CLSM/RSTFILE/LIS_enRST_${last_yyyy}${last_mm}${last_mm_max_day}2330.d01.nc "
if [ ! -f $FORECAST/SAForecast_CLSM/RSTFILE/LIS_enRST_${last_yyyy}${last_mm}${last_mm_max_day}2330.d01.nc ]; then
    echo "  LDT run failed... Check the LDT log files for futher instructions"
    exit 1
fi


echo "  Updating lis configure..."
sed -i "/^\s*Starting year/c\Starting year:                             $yyyy" lis.config.ensemble
sed -i "/^\s*Starting month/c\Starting month:                            $mm" lis.config.ensemble
             #              Starting day:                              1

next_mm=`date -d "$mmm 1 $yyyy +1 month" "+%m"`
next_yyyy=`date -d "$mmm 1 $yyyy +1 month" "+%Y"`
next_mm_max_day=`cal $next_mm $next_yyyy | awk 'NF {DAYS = $NF}; END {print DAYS}'`

sed -i "/^\s*Ending year/c\Ending year:                               $next_yyyy" lis.config.ensemble
sed -i "/^\s*Ending month/c\Ending month:                              $next_mm" lis.config.ensemble
sed -i "/^\s*Ending day/c\Ending day:                                $next_mm_max_day" lis.config.ensemble

sed -i "/^\s*Output directory/c\Output directory:                  \".\/CLSM_EN_$yyyy$mm \"" lis.config.ensemble
sed -i "/^\s*Diagnostic output file/c\Diagnostic output file:                 \".\/logs\/$yyyy$mm\/lislog\"" lis.config.ensemble
sed -i "/^\s*CLSM F2.5 restart file/c\CLSM F2.5 restart file:              .\/RSTFILE\/LIS_enRST_${last_yyyy}${last_mm}${last_mm_max_day}2330.d01.nc" lis.config.ensemble

echo "  Begin to run LIS" `date`
bash RunLIS.sh
echo "  LIS end at " `date`



