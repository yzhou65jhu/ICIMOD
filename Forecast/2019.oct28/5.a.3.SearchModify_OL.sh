#!/bin/sh

## Specify a name for the job allocation
#SBATCH --job-name=Forecast
## Specify a filename for standard output
#SBATCH --output=./logs/tryrun.log
## Specify a filename for standard error
#SBATCH --error=./logs/tryrun.err
## Set a limit on the total run time
#SBATCH --time=3:00:00
## Enter NCCS Project ID below:
#SBATCH --account s1525
## Adjust node, core, and hardware constraints
#SBATCH --ntasks=140 --constraint=hasw
# Substitute your e-mail here
#SBATCH --mail-user=yzhou65@jhu.edu
#SBATCH --mail-type=ALL
##SBATCH --qos=long




RUNLIS=run_LIS_ensemble
SCRIPTS=`pwd`

CONFIGNAME=lis.config.noahmp.ensemble
OUTPUTFOLDER=Noah3.6MP_ensemble

PROJECT=$SCRIPTS/$OUTPUTFOLDER
SURFACEMODEL=SURFACEMODEL
EYYYYMM=210001
EYYYY=2100
EMM=01

cd $PROJECT/$SURFACEMODEL

LASTYYYYMM=$(ls -1 | sort | tail -2 | head -1)

LASTYYYY=$(echo $LASTYYYYMM | cut -b 1-4)
LASTMM=$(echo $LASTYYYYMM | cut -b 5-6 )

# in STARTMM, make sure switch to decimalism(10#), or else you will run into trouble!
STARTMM=$((10#$LASTMM + 1))
STARTYYYY=$((LASTYYYY + (STARTMM - 1) / 12))
STARTMM=$(((STARTMM - 1) % 12 + 1 ))
STARTYYYYMM=$(printf "%s%02d\n" $STARTYYYY $((STARTMM)))

cd $PROJECT/$SURFACEMODEL/$LASTYYYYMM
RSTFILE=$(ls -1 | grep -e RST | sort | tail -1)

cd $SCRIPTS

lastDays=$(cal $LASTMM $LASTYYYY | awk 'NF {DAYS = $NF}; END {print DAYS}')

cp $CONFIGNAME ${CONFIGNAME}.$STARTYYYYMM

if [ $STARTYYYYMM -le $EYYYYMM ]; then
    sed -i "/^[^#]/s/\(Noah-MP.3.6 restart file: \).*/\1                  .\/${OUTPUTFOLDER}\/SURFACEMODEL\/${LASTYYYYMM}\/$RSTFILE/" ${CONFIGNAME}.$STARTYYYYMM
	sed -i "/^[^#]/s/\(Start mode:\).*/\1                                restart/" ${CONFIGNAME}.$STARTYYYYMM
	sed -i "/^[^#]/s/\(Starting year:\).*/\1                             $LASTYYYY/" ${CONFIGNAME}.$STARTYYYYMM
	sed -i "/^[^#]/s/\(Starting month:\).*/\1                            $LASTMM/" ${CONFIGNAME}.$STARTYYYYMM
    sed -i "/^[^#]/s/\(Starting day:\).*/\1                              $lastDays/" ${CONFIGNAME}.$STARTYYYYMM
    sed -i "/^[^#]/s/\(Starting hour:\).*/\1                             23/" ${CONFIGNAME}.$STARTYYYYMM
    sed -i "/^[^#]/s/\(Starting minute:\).*/\1                           45/" ${CONFIGNAME}.$STARTYYYYMM

    NYYYY=`date -d "$LASTYYYY-$LASTMM-01 +2months" "+%Y"`
    NMM=`date -d "$LASTYYYY-$LASTMM-01 +2months" "+%m"`
    sed -i "/^[^#]/s/\(Ending year:\).*/\1                               $NYYYY/" ${CONFIGNAME}.$STARTYYYYMM
#    sed -i "/^[^#]/s/\(Ending year:\).*/\1                               2100/" ${CONFIGNAME}.$STARTYYYYMM
    sed -i "/^[^#]/s/\(Ending month:\).*/\1                              $NMM/" ${CONFIGNAME}.$STARTYYYYMM
    sed -i "/^[^#]/s/\(Ending day:\).*/\1                                01/" ${CONFIGNAME}.$STARTYYYYMM
fi

cp $RUNLIS.sh $RUNLIS.$STARTYYYYMM.sh
sed -i "s/mpirun.*/mpirun -np 140 .\/LIS_sep23 -f ${CONFIGNAME}.$STARTYYYYMM/g" $RUNLIS.$STARTYYYYMM.sh
sed -i "/#SBATCH --nodes/c\#SBATCH --ntasks=140 --constrant=hasw" $RUNLIS.$STARTYYYYMM.sh
sed -i "s/^\(#SBATCH --job-name=\).*/\1f$STARTYYYYMM/" $RUNLIS.$STARTYYYYMM.sh
sh $RUNLIS.$STARTYYYYMM.sh



#sbatch -d afterany:jobID run_da_next.sh
