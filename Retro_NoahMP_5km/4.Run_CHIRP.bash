#!/bin/bash

export RETRO_CHIRPS=~/data1/LISRUN/Retro_NoahMP_GDAS_Chirps/
export RETRO_CHIRP=~/data1/LISRUN/Retro_NoahMP_GDAS_Chirp/
export RETRO_BOTH=~/data1/LISRUN/Retro_NoahMP_GDAS_CHIRP[S]
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

cd $RETRO_CHIRP/RSTFILE
ln -sf $RETRO_CHIRPS/NoahMP/SURFACEMODEL/$LASTYYYYMM/$RSTFILE .

cd $RETRO_CHIRP/FORCING

YYYYMM=`ls -1 | sort | tail -n 1`

cd $RETRO_CHIRP/FORCING/$YYYYMM
FILE=`ls -1 | sort | tail -n 1`
EYYYY=${FILE:9:4}
EMM=${FILE:13:2}
EDD=${FILE:15:2}

cd $RETRO_CHIRP

sed -i "s/^\(Noah-MP.3.6 restart file: \).*/\1                 .\/RSTFILE\/$RSTFILE/" lis.config.noahmp
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

cd $RETRO_CHIRP/NoahMP/SURFACEMODEL/

for yyyymm in `ls -1d 2?????`; do
    mkdir -p $RETRO_BOTH/ori/$yyyymm/
    cd $RETRO_BOTH/ori/$yyyymm/
    ln -sf $RETRO_CHIRP/NoahMP/SURFACEMODEL/$yyyymm/LIS_HIST_*.nc .
done

cd $RETRO_CHIRPS/NoahMP/SURFACEMODEL/
for yyyymm in `ls -1d 2?????`; do
    mkdir -p $RETRO_BOTH/ori/$yyyymm/
    cd $RETRO_BOTH/ori/$yyyymm/
    ln -sf $RETRO_CHIRPS/NoahMP/SURFACEMODEL/$yyyymm/LIS_HIST_*.nc .
done






