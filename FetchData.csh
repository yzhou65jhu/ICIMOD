#!/bin/csh -f
# NCEP server transition to HTTP base transfer.  Aug 2015
# Yifan: Updated the script for Monsoon server.  Feb 2018

echo "starting to fetch data"
date
#
# Settings for getting GDAS data files from NOAA
#

set SERVERHOST  = http://nomads.ncep.noaa.gov
set DIRNAME1    = pub/data/nccf/com/gfs/prod

#
# Settings for the LOCAL directory
#
set LOCAL1  = /data1/MET_FORCING/GDAS/download/TEMP  
# Replace this with a temporary folder for downloaded data
set LOCAL2  = /data1/MET_FORCING/GDAS/download		
# Replace this with a folder for downloaded data
set SCRIPTS = /data1/SCRIPTS/GDAS 				
# Replace this with a folder for GRIB1 data
set DATA  = /data1/MET_FORCING/GDAS					
#
# Replace this with the folder that contains this script
#

echo $LOCAL1
echo $LOCAL2

mkdir -p $LOCAL2
mkdir -p $LOCAL1

#
# Determine file dates available on NCEP server
#

cd $SCRIPTS
rm -f index.html*
wget -S $SERVERHOST/$DIRNAME1/

#
# Compare with files stored in local temporary location
#
cd $LOCAL1
grep -a \"gdas $SCRIPTS/index.html | awk -F'"' '{print $2}' > remote-dir2
ls | grep "gdas." | awk '{print $0 "/"}'  > local-dir
comm -13 remote-dir2 local-dir > del-dir
#comm -23 remote-dir2 local-dir > missing-dir
#comm -12 remote-dir2 local-dir > comm-dir
#comm -23 remote-dir2 /data1/SCRIPTS/converted-dir > add-dir
 

# Compare missing-dir with already converted files
 
 
#
# Delete old directories and add new
#
# foreach commdir (`cat comm-dir | cut -c 6-13`)
#   mkdir -p $LOCAL2/gdas.$commdir
# end
#foreach adddir (`cat add-dir | cut -c 6-13`)
#   mkdir -p gdas.$adddir
#   mkdir -p $LOCAL2/gdas.$adddir
#end
foreach deldir (`cat del-dir | cut -c 6-13`)
  rm -rf gdas.$deldir
end
rm del-dir # local-dir add-dir 


#
# Copy over files if it doesn't exist already
# 
foreach dir (`cat remote-dir2`)
	cd $LOCAL1/
        echo "downloading $dir"
        mkdir -p $dir
        cd $dir
#	wget -nv -r -l1 -N -nH --cut-dirs=7 -A grib2 http://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/$dir/00
	wget -N -c -r -l1 -nH --cut-dirs=9 -A grib2 http://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/$dir/00/
	wget -N -c -r -l1 -nH --cut-dirs=9 -A grib2 http://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/$dir/06/
	wget -N -c -r -l1 -nH --cut-dirs=9 -A grib2 http://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/$dir/12/
	wget -N -c -r -l1 -nH --cut-dirs=9 -A grib2 http://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/$dir/18/
	cp -r $LOCAL1/$dir  $LOCAL2/
end

cd $LOCAL1/
#rm add-dir

chmod 755 $LOCAL1/gdas*
chmod 755 $LOCAL2/gdas*

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "Finish fetching data"
date

