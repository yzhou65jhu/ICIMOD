#!/bin/bash

#Set whatever environment PATH needed for LIS to run here.
#Use absolute path to set system path, because no environment variable is set in the cronjob environment.
#source $HOME/.bash_aliases        				   #This is important for cronjob to work. In cronjob setting, no PATH or variable is set. 

#echo $PATH > path.txt

#Set basic path variables
source ~/.bashrc

PROJECT=/home/kshakya/data1/GDAS_5KM_Noah3.6				 #The folder path for the project where contains the lis configure files
MODEL=Noah3.6_GDAS_5km_output					   #The model result folder name
SURFACEMODEL=SURFACEMODEL						   #Surface model result folder name
ROUTING=ROUTING									   #Routing model result folder name
SCRIPTS=/data1/SCRIPTS/						   #Script folder
RESTARTFILE=lis.config_noah3.6							   #The name of your LIS configure file
FORCING=/data1/MET_FORCING/GDAS						 #The folder name for your GDAS forcing 
LOGS=/home/kshakya/data1/SCRIPTS/logs/Noah_logs/

date=`date | cut -d' ' -f6,2,3 | sed -e 's/ /_/g'`
file=$LOGS/Noah_${date}.log


#Get the start year and month of LIS run 
cd $PROJECT/$MODEL/$SURFACEMODEL
STARTYYYYMM=$(ls -1 | sort | tail -1)

cd $STARTYYYYMM
SURFACERSTFILE=$(ls -1 | grep -e RST | sort | tail -1)

if [ -z "$SURFACERSTFILE"  ]; then
   cd $PROJECT/$MODEL/$SURFACEMODEL
   STARTYYYYMM=$(ls -1 | sort | tail -n 2 | head -n 1)
   cd $STARTYYYYMM
   SURFACERSTFILE=$(ls -1 | grep -e RST | sort | tail -1)
fi


STARTYYYY=$(echo $STARTYYYYMM | cut -b 1-4)
STARTMM=$(echo $STARTYYYYMM | cut -b 5-6 )

cd $STARTYYYYMM

#Delete redundant files, leaving only the last two restart files in each month
if [ "$(ls -1 | grep -e RST | wc -l)" -gt 2 ]; then
	rm $(ls -1 | grep -e RST | sort | head -n -2)
fi

#Get the surface model restart file name
SURFACERSTFILE=$(ls -1 | grep -e RST | sort | tail -1)
echo "$STARTYYYYMM/$SURFACERSTFILE" >> $file

#Get the start day and hour of LIS run 
STARTDD=$(echo $SURFACERSTFILE | cut -b 22-23)
STARTHH=$(echo $SURFACERSTFILE | cut -b 24-25)
STARTMI=$(echo $SURFACERSTFILE | cut -b 26-27)


#Delete redundant files, leaving only the last two restart files in each month
#cd $PROJECT/$MODEL/$ROUTING
#cd $STARTYYYYMM
#if [ "$(ls -1 | grep -e RST | wc -l)" -gt 2 ]; then
#	rm $(ls -1 | grep -e RST | sort | head -n -2)
#fi
#ROUTINGRSTFILE=$(ls -1 | grep -e RST | sort | tail -1)

#Get the ending time of LIS run 
cd $FORCING
export ENDYYYYMM=$(ls -1 | grep -e 20 | sort | tail -1)
export ENDYYYY=$(echo $ENDYYYYMM | cut -b 1-4)
export ENDMM=$(echo $ENDYYYYMM | cut -b 5-6)
cd $ENDYYYYMM
ENDDD=$(ls -1 | grep -e 20 | sort | tail -1 | cut -b 7-8)
ENDHH=$(ls -1 | grep -e 20 | sort | tail -1 | cut -b 9-10)

#Update LIS configure file 
echo "updating configure file" >> $file 2>&1
cd $PROJECT

#sed -i "/^\s*HYMAP routing model restart file/c\HYMAP routing model restart file:          \.\/$MODEL\/$ROUTING\/$STARTYYYYMM\/$ROUTINGRSTFILE" $RESTARTFILE
sed -i "/^\s*Noah.3.6 restart file/c\Noah.3.6 restart file:                    \.\/$MODEL\/$SURFACEMODEL\/$STARTYYYYMM\/$SURFACERSTFILE" $RESTARTFILE
sed -i "/^\s*Starting year/c\Starting year:                             $STARTYYYY" $RESTARTFILE
sed -i "/^\s*Starting month/c\Starting month:                            $STARTMM" $RESTARTFILE
sed -i "/^\s*Starting day/c\Starting day:                              $STARTDD" $RESTARTFILE
sed -i "/^\s*Starting hour/c\Starting hour:                             $STARTHH" $RESTARTFILE
sed -i "/^\s*Starting minute/c\Starting minute:                             $STARTMI" $RESTARTFILE

sed -i "/^\s*Ending year/c\Ending year:                               $ENDYYYY" $RESTARTFILE
sed -i "/^\s*Ending month/c\Ending month:                              $ENDMM" $RESTARTFILE
sed -i "/^\s*Ending day/c\Ending day:                                $ENDDD" $RESTARTFILE
sed -i "/^\s*Ending hour/c\Ending hour:                               $ENDHH" $RESTARTFILE

echo "Updating done"

echo "$STARTYYYYMM$STARTDD$STARTHH"
echo "$ENDYYYYMM$ENDDD$ENDHH"

if [ "$STARTYYYYMM$STARTDD$STARTHH" -lt "$ENDYYYYMM$ENDDD$ENDHH" ]; then
	echo "Running LIS..." >> $file
	echo "start time:" `date` >> $file 2>&1
	mpirun -np 64  LIS_LOCAL -f $RESTARTFILE >> $file 2>&1						#Replace 16 with the number of cores you need and the command to run LIS
	echo "end time:" `date` >> $file 2>&1
	echo "done." >> $file 2>&1
else
        echo "No need run LIS because no new data is provided" >> $file
fi


cd $PROJECT/$MODEL/$SURFACEMODEL
cp -ruv * ~/zData/GDAS_5KM_RUN/Noah3.6_GDASmet_pre_10_final/SURFACEMODEL/ >> $file 2>&1
