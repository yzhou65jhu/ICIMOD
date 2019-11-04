##Iportant to set environment for wgrib2 and cnvgrib!!!
#source ~/.bash_profile
source ~/.bashrc

for file in `ls -1 *z.sfluxgrbf[0-1][0-9].grib2`
do
  partialfile=`echo $file | awk -F. '{print $3}'`

 ### Determine date-time stamp (yyyymmdd) to use in data file name.
  DATESTAMP=`wgrib2 -v $file | head -1 | cut -c 7-16`
  NEWFILE=$DATESTAMP.gdas1.$partialfile.sg.grib2
  FINALFILE=$DATESTAMP.gdas1.$partialfile.sg
  echo $NEWFILE
  echo $FINALFILE

 ##################################################################
 ### FORCING VARIABLES --------------------------------------------
 ##################################################################
  wgrib2 $file | grep ":DLWRF:surface" | wgrib2 -i $file -grib $NEWFILE  
  wgrib2 $file | grep ":DSWRF:surface" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":PRATE:surface" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":CPRAT:surface" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":UGRD" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":VGRD" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":TMP:2 m" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":SPFH:2 m" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":PRES:surface" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":ALBDO:surface" | wgrib2 -i $file -append -grib $NEWFILE  

  #################################################################
  ### ADDITIONAL VARIABLES ----------------------------------------
  #################################################################
  wgrib2 $file | grep ":SHTFL:surface" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":LHTFL:surface" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":TMP:surface" | wgrib2 -i $file -append -grib $NEWFILE  
# 2 soil layers in OSU model before May 31, 2005
#  wgrib2 $file | grep ":SOILW:0-10" | wgrib2 -i $file -append -grib $NEWFILE  
#  wgrib2 $file | grep ":SOILW:10-200" | wgrib2 -i $file -append -grib $NEWFILE  
#  wgrib2 $file | grep ":TMP:0-10" | wgrib2 -i $file -append -grib $NEWFILE  
#  wgrib2 $file | grep ":TMP:10-200" | wgrib2 -i $file -append -grib $NEWFILE  
# 4 soil layers in NOAH model from May 31, 2005 [cm]
# unit in [m] from Jan 28, 2008
  wgrib2 $file | grep ":SOILW:0-0.1 m" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":SOILW:0.1-0.4 m" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":SOILW:0.4-1 m" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":SOILW:1-2 m" | wgrib2 -i $file -append -grib $NEWFILE  
## Renamed Soil Temperature from TMP to TSOIL on 2015.02.03
  wgrib2 $file | grep ":TMP:0-0.1 m" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":TMP:0.1-0.4 m" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":TMP:0.4-1 m" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":TMP:1-2 m" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":WEASD:surface" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":ULWRF:surface" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":USWRF:surface" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":GFLUX:surface" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":WATR:surface" | wgrib2 -i $file -append -grib $NEWFILE  
  wgrib2 $file | grep ":PEVPR:surface" | wgrib2 -i $file -append -grib $NEWFILE  
  #################################################################

############################
## Convert back to GRIB1  ##
############################
#  env
  cnvgrib -g21 $NEWFILE $FINALFILE

done
chmod 755 *.sg
rm -f *sg.grib2


