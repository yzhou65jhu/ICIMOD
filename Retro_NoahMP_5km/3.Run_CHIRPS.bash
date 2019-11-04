#!/bin/bash

export RETRO_CHIRPS=~/data1/LISRUN/Retro_NoahMP_GDAS_Chirps/
export SC=/home/kshakya/data1/SCRIPTS/Retro_NoahMP_5km/

cd $RETRO_CHIRPS/NoahMP/SURFACEMODEL/

LASTYYYYMM=$( ls -1d 20???? | sort | tail -n 1 )

cd $RETRO_CHIRPS/NoahMP/SURFACEMODEL/$LASTYYYYMM

if [ "$(ls -1 | grep -e RST | wc -l)" -lt 1 ]; then
   cd $RETRO_CHIRPS/NoahMP/SURFACEMODEL
   LASTYYYYMM=$(ls -1d 20???? | sort | tail -n 2 | head -n 1)
fi

cd $RETRO_CHIRPS/NoahMP/SURFACEMODEL/$LASTYYYYMM
RSTFILE=$(ls -1 | grep -e RST | sort | tail -n 1)

SYYYY=${RSTFILE:17:4}
SMM=${RSTFILE:21:2}
SDD=${RSTFILE:23:2}
SMI=${RSTFILE:25:2}
SSS=${RSTFILE:27:2}

cd $RETRO_CHIRPS/FORCING

YYYYMM=`ls -1 | sort | tail -n 1`

cd $RETRO_CHIRPS/FORCING/$YYYYMM
FILE=`ls -1 | sort | tail -n 1`
EYYYY=${FILE:9:4}
EMM=${FILE:13:2}
EDD=${FILE:15:2}
EMI=${FILE:17:2}
ESS=${FILE:19:2}

cd $RETRO_CHIRPS

sed -i "s/^\(Noah-MP.3.6 restart file: \).*/\1                .\/NoahMP\/SURFACEMODEL\/$LASTYYYYMM\/$RSTFILE/" lis.config.noahmp
sed -i "s/^\(Start mode:\).*/\1                                restart/" lis.config.noahmp
sed -i "s/^\(Starting year:\).*/\1                             $SYYYY/" lis.config.noahmp
sed -i "s/^\(Starting month:\).*/\1                            $SMM/" lis.config.noahmp
sed -i "s/^\(Starting day:\).*/\1                              $SDD/" lis.config.noahmp
sed -i "s/^\(Starting hour:\).*/\1                             $SMI/" lis.config.noahmp
sed -i "s/^\(Starting minute:\).*/\1                           $SSS/" lis.config.noahmp

sed -i "s/^\(Ending year:\).*/\1                               $EYYYY/" lis.config.noahmp
sed -i "s/^\(Ending month:\).*/\1                              $EMM/" lis.config.noahmp
sed -i "s/^\(Ending day:\).*/\1                                $EDD/" lis.config.noahmp


mpirun -np 64 ./LIS -f lis.config.noahmp
