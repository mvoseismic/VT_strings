#!/usr/bin/bash
#
# Gets select helicorder plots for a date
#
# R.C. Stewart, 2024-08-30
#

if [ -z "$1" ]
then
	echo "Argument needed, twit!"
else
	dateHeli=$1
    find /mnt/mvofls2/Seismic_Data/monitoring_data/helicorder_plots_multi -name "*${dateHeli}*" -print0 | xargs -0 cp --target-directory=.
    find /mnt/mvofls2/Seismic_Data/monitoring_data/helicorder_plots -name "MSS1*${dateHeli}*" -print0 | xargs -0 cp --target-directory=.
fi
