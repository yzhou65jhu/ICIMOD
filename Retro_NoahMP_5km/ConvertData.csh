#roko Beaudoing: Migrated to Oasis, Oct 2013.
# Hiroko Beaudoing: Modified for GRIB2, Jan 2008.
# Hiroko Beaudoing: Adopted to the NCEP ftp server change, Aug 2017.
# Yifan: Updated the script for Monsoon server. Feb. 2018


# This script downloads and preprocess GDAS data for LIS.
# Calls extract.gdas382.bash that extracts relevant fields
# and converts from GRIB2 to GRIB1 format.
# Required library/utility: wgrib2, cnvgrib

#
# Settings for the LOCAL directory
#
set LOCAL2  = /data1/MET_FORCING/GDAS/download  # Replace this with a folder for downloaded data
set DATA  = /data1/MET_FORCING/GDAS			   # Replace this with a folder for GRIB1 data
set DATA2  = /data1/MET_FORCING/GDAS/GRIB2      # Replace this with a folder for GDAS GRIB2 data
set SCRIPTS = /data1/SCRIPTS/Retro_NoahMP_5km			   # Replace this with a folder which contains this script

# Download and place raw data in LOCAL2
cd $LOCAL2

# Since files are downloaded 4 times/day, avoid re-processing the files
# that are already processed

## A) limit days to process
# set gdasdir = `ls | grep -e gdas | cut -c 1-13 | tail -1`
## B) process all in LOCAL2
set gdasdir = `ls | grep -e gdas | cut -c 1-13 `

@ jj = 1
while ( $jj <= $#gdasdir )
    echo 'Working on GDAS files from: '$gdasdir[$jj]
    cd $LOCAL2/$gdasdir[$jj]/
    foreach pfile (`ls -1 gdas*`)
                echo "pfile"
		set hh = `echo $pfile | cut -c 7-8 `
                echo "hh=$hh"
		set fh = `echo $pfile | cut -c 21-22 `
		set dirname = `echo $gdasdir[$jj] | cut -c 6-11 `
		set yyyymmdd = `echo $gdasdir[$jj] | cut -c 6-13 `

		echo "name:" $DATA/$dirname/$yyyymmdd$hh.gdas1.sfluxgrbf$fh.sg
		## RENAME and SAVE original GRIB2 data (same filename as GRIB1)
		mkdir -p $DATA2/$dirname
		cp -vp $pfile $DATA2/$dirname/$yyyymmdd$hh.gdas1.sfluxgrbf$fh.sg
		## extract and conver to GRIB1 
		if ( ! -e $DATA/$dirname/$yyyymmdd$hh.gdas1.sfluxgrbf$fh.sg ) then
                        echo "we are in $DATA/$dirname/$yyyymmdd$hh.gdas1.sfluxgrbf$fh.sg"
			cp $SCRIPTS/extract.gdas382.bash /$LOCAL2/$gdasdir[$jj]
			bash $LOCAL2/$gdasdir[$jj]/extract.gdas382.bash $pfile
			#rm $LOCAL2/$gdasdir[$jj]/extract.gdas382.bash
			mkdir -m 755 -p $DATA/$dirname/
			ls -1 *sg* | xargs -i -t mv {} $DATA/$dirname/{}
		else
			## double check the file size
			set fsize = `ls -l $DATA/$dirname/$yyyymmdd$hh.gdas1.sfluxgrbf$fh.sg | awk '{print $6}'`
			echo 'fsize = '$fsize
			if ( $fsize > 0 ) then
				echo 'file is ok...' 
			else
				echo '<< corrupt file -> removing>>' 
				rm -v $DATA/$dirname/$yyyymmdd$hh.gdas1.sfluxgrbf$fh.sg 
				cp $SCRIPTS/extract.gdas382.bash /$LOCAL2/$gdasdir[$jj]
				bash $LOCAL2/$gdasdir[$jj]/extract.gdas382.bash $pfile
				rm $LOCAL2/$gdasdir[$jj]/extract.gdas382.bash
				mkdir -m 755 -p $DATA/$dirname/
				ls -1 *sg* | xargs -i -t mv {} $DATA/$dirname/{}
			endif
		endif
	end
	set nof = `ls -1 | wc -l`
#	if ($nof >= 16) then
#               rm -r $LOCAL2/$gdasdir[$jj]
#	       echo "$gdasdir[$jj]/" >> $LOCAL2/converted-dir
#	endif
	@ jj++
end

sort $LOCAL2/converted-dir > $LOCAL2/tempFile
mv $LOCAL2/tempFile $LOCAL2/converted-dir

echo "END batchprocgdas "
#/bin/bash: wq
