#!/bin/bash

yyyy=2019
mmmdd=oct28

sed -i "s/^\(yyyy=\).*/\1$yyyy/" 0.CollectGEOS5_prediction.sh 
sed -i "s/^\(mmmdd=\).*/\1$mmmdd/" 0.CollectGEOS5_prediction.sh 


sed -i "s/^\(yyyy=\).*/\1$yyyy/" 1.RunGARD.sh
sed -i "s/^\(mmmdd=\).*/\1$mmmdd/" 1.RunGARD.sh

sed -i "s/^\(yyyy=\).*/\1$yyyy/" 2.PostGARD.sh
sed -i "s/^\(mmmdd=\).*/\1$mmmdd/" 2.PostGARD.sh

sed -i "s/^\(yyyy=\).*/\1$yyyy/" 3.DisAgg.sh
sed -i "s/^\(mmmdd=\).*/\1$mmmdd/" 3.DisAgg.sh

sed -i "s/^\(yyyy=\).*/\1$yyyy/" 4.PrepareForLIS.sh
sed -i "s/^\(mmmdd=\).*/\1$mmmdd/" 4.PrepareForLIS.sh

sed -i "s/^\(yyyy=\).*/\1$yyyy/" 5.PostProcess.sh
sed -i "s/^\(mmmdd=\).*/\1$mmmdd/" 5.PostProcess.sh










