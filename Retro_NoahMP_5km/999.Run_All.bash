#!/bin/bash

source ~/.bashrc

YYYYMMDD=`date "+%Y.%m.%d"`

cd /home/kshakya/data1/SCRIPTS/Retro_NoahMP_5km/
mkdir -p logs/$YYYYMMDD
bash 0.Download_Schedule.bash > logs/$YYYYMMDD/0.log 2>&1
bash 1.Obtain_CHIRPS.bash > logs/$YYYYMMDD/1.log 2>&1
bash 2.Obtain_CHIRP.bash > logs/$YYYYMMDD/2.log 2>&1
bash 3.Run_CHIRPS.bash > logs/$YYYYMMDD/3.log 2>&1
bash 4.Run_CHIRP.bash > logs/$YYYYMMDD/4.log 2>&1
bash 5.GetDekad.bash > logs/$YYYYMMDD/5.log 2>&1
bash 6.GetMonthly.bash > logs/$YYYYMMDD/6.log 2>&1
bash 7.Get3Monthly.bash > logs/$YYYYMMDD/7.log 2>&1



