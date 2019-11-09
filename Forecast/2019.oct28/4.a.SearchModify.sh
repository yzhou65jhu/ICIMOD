#!/bin/sh

#This scripts is a supplementary script for LIS forecast simulation. This script is only used to restart forecast simulation if the forecast simulation is interrupted for whatever reason. This script 1) searches for the latest restart file, and 2) continue the forecast simulation with the latest restart file. 


#Set initial forecast date and necessary paths.
yyyy=2019
mmmdd=oct28

export SCRIPTS=/data1/LISRUN/Forecast/ForecastRun/$yyyy/$mmmdd/

RUNLIS=run_LIS_ensemble
SCRIPTS=`pwd`

CONFIGNAME=lis.config.noahmp.ensemble
OUTPUTFOLDER=Noah3.6MP_ensemble

PROJECT=$SCRIPTS/$OUTPUTFOLDER
SURFACEMODEL=SURFACEMODEL
EYYYYMM=210001
EYYYY=2100
EMM=01

#1) Search for the latest restart file
#Enter the lis output folder
cd $PROJECT/$SURFACEMODEL
#Get the second lastest folder which generate contains the latest restart file.
LASTYYYYMM=$(ls -1 | sort | tail -2 | head -1)

LASTYYYY=$(echo $LASTYYYYMM | cut -b 1-4)
LASTMM=$(echo $LASTYYYYMM | cut -b 5-6 )

# in STARTMM, make sure switch to decimalism(10#). Bash recoginze number starts with 0 as octonary number and will report error for 09.
#Calculate the starting date/time for this simulation
STARTMM=$((10#$LASTMM + 1))
STARTYYYY=$((LASTYYYY + (STARTMM - 1) / 12))
STARTMM=$(((STARTMM - 1) % 12 + 1 ))
STARTYYYYMM=$(printf "%s%02d\n" $STARTYYYY $((STARTMM)))

#Get the restart file name in the output folder.
cd $PROJECT/$SURFACEMODEL/$LASTYYYYMM
RSTFILE=$(ls -1 | grep -e RST | sort | tail -1)

cd $SCRIPTS

lastDays=$(cal $LASTMM $LASTYYYY | awk 'NF {DAYS = $NF}; END {print DAYS}')

#2) Make a copy of the LIS configure file.
cp $CONFIGNAME ${CONFIGNAME}.$STARTYYYYMM

#Modify LIS simulation restart file path, start date and time.
if [ $STARTYYYYMM -le $EYYYYMM ]; then
    sed -i "/^[^#]/s/\(Noah-MP.3.6 restart file: \).*/\1                  .\/${OUTPUTFOLDER}\/SURFACEMODEL\/${LASTYYYYMM}\/$RSTFILE/" ${CONFIGNAME}.$STARTYYYYMM
    sed -i "/^[^#]/s/\(Start mode:\).*/\1                                restart/" ${CONFIGNAME}.$STARTYYYYMM
    sed -i "/^[^#]/s/\(Starting year:\).*/\1                             $LASTYYYY/" ${CONFIGNAME}.$STARTYYYYMM
    sed -i "/^[^#]/s/\(Starting month:\).*/\1                            $LASTMM/" ${CONFIGNAME}.$STARTYYYYMM
    sed -i "/^[^#]/s/\(Starting day:\).*/\1                              $lastDays/" ${CONFIGNAME}.$STARTYYYYMM
    sed -i "/^[^#]/s/\(Starting hour:\).*/\1                             23/" ${CONFIGNAME}.$STARTYYYYMM
    sed -i "/^[^#]/s/\(Starting minute:\).*/\1                           45/" ${CONFIGNAME}.$STARTYYYYMM
#    sed -i "/^[^#]/s/\(Ending year:\).*/\1                               2100/" ${CONFIGNAME}.$STARTYYYYMM
#    sed -i "/^[^#]/s/\(Ending month:\).*/\1                              01/" ${CONFIGNAME}.$STARTYYYYMM
#    sed -i "/^[^#]/s/\(Ending day:\).*/\1                                01/" ${CONFIGNAME}.$STARTYYYYMM
fi

#Restart the LIS forecast simulation.
cp $RUNLIS.sh $RUNLIS.$STARTYYYYMM.sh
sed -i "s/mpirun.*/mpirun -np 81 .\/LIS -f ${CONFIGNAME}.$STARTYYYYMM/g" $RUNLIS.$STARTYYYYMM.sh
sh $RUNLIS.$STARTYYYYMM.sh


