#!/usr/bin/bash

# Commented out until SEISAN problems with large files sorte, RCS 2024-09-18
#./plot_spectrograms.pl
./plot_a_lot.py

mv *.png ../data/all_plots
mv *.mseed ../data/mseed_files

./plotPs.pl

cd ../data/event_lists/0-new
mv *.txt ..

cd ../../seisan_files/0-new
mv * ..

