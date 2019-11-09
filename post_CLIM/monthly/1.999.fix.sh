export ff=/discover/nobackup/projects/grace/Yifan/LISRUN/SALDAS/Forecast/hindcast_v1/hindcast_CLIM/monthly

cd $ff
for mm in `seq -w 5 11`; do
    mv daily.$mm.avg.nc monthly.$mm.avg.nc
    mv daily.$mm.std.nc monthly.$mm.std.nc
done
