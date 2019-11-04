#!/bin/bash

export ROOT=/home/kshakya/
export SCRIPT=${ROOT}/data1/SCRIPTS
export LOGS=${SCRIPT}/data1/logs/forecast_CLSM_logs

date=`date | cut -d' ' -f6,2,3 | sed -e 's/ /_/g'`
file=$LOGS/forecast_${date}.log

cd $SCRIPTS
bash -e run_forecast.bash > $file 2&>1



