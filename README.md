# VT_strings

Scripts for analysing VT string data.

## plotBigStrings

Create special plot comparing largest strings.

## plotOneStation

Create montage of one-station plots for strings.

## plotStrings

Various plots of VT strings.

### plot0.sh

- Creates plots and data for all strings in *./data/event_lists/0-new* and *data/seisan_files/0-new*.
- Calls *plot_a_lot.py* and *plotPs.pl*.

### plot_a_lot.py

* Creates multi-channel plots for all strings in *./data/event_lists/0-new* and *data/seisan_files/0-new*.
* Saves plots in *data/all_plots*.
* Creates miniseed files for all strings in *./data/event_lists/0-new* and *data/seisan_files/0-new*.
* Saves files in *./data/mseed_files*.
* Uses *SAC*.

### plotPs.pl

* Creates montage of event waveforms for all strings in *./data/event_lists/0-new* and *data/seisan_files/0-new*.
* Used to identify if event waveforms are repeating.
* Plots stored in *./data/polarities/plots*.
* Usual practice is to delete all the waveform plots for signals that are small and unclear, then repeat the *montage* command (handily printed out at the end of the script).

### plotSpecial3Montage.pl

* Creates a script to create a montage that compares waveforms and spectrograms.
* Prompts for string to plot.
* Script saved as *~seisan/tmp--DONT_USE/special3Montage/doit.sh*.
* Uses *getnPlot*.

### plot_spectrograms.pl

* Creates spectrograms  for all strings in *./data/event_lists/0-new* and *data/seisan_files/0-new*.
* Uses *SAC* and *wavetool*.
* Not working due to *SEISAN* problem on *opsproc3*.

## scripts

Basic analysis of VT strings.

### check_all.pl

* Lists numbers of various files in *data* for each string.

### check_helis.pl

* Lists number of helicorder plots in *data/heli_plots* for each string.

### event_list_info.m

* Lists string information.
* Obsolete.

### event_lists.pl

* Lists string information.
* Obsolete.

### excel2webobs.pl

* Prints text that can be cut and paste into *Webobs* entry for each string.
* Usage:
```
$ ./excel2webobs.pl 2> /dev/null
```


### fetchHelis.sh

* Copies MSS1 helicorder plots and multi-station helicorder plots to current directory.
* Usage fetchHelis.sh 20250101

### station_info.m

* Creates a plot showing station availability for all strings.
* Uses data from *SeismicityDiary.xlsx*.

## stringAnalysis

Advanced analysis of VT strings.

### analyseStrings.m

* Creates various plots for a string.
* Plots stored in *./plots* directory.

### calcMoments.m

* Calculates Seismic Moment for every string.
* Results stored in */mnt/mvofls2/Seismic_Data/monitoring_data/megaplot2/fetchedVTstringsPlus.mat*.

### calcVtRates.m, calcVtRatesPlot.m

* Calculates and plots VT event rates before and after strings.

### cumEventAmp

Creates plots of cumulative event amplitude for each string.
 
### listStrings.m, listStrings2.m

* List string information.

### plotStringStuff.m

* Plots string information against time.
 
### vtstringStats.m

* Calculates and plots analysis of string meta-data.
* Output in *vtstringStats.txt*.

## stringsVgas

Create plot of SO2 flux measurements for each string.

## Author

Roderick Stewart, Dormant Services Ltd

rod@dormant.org

https://services.dormant.org/

## Version History

* 1.0-dev
    * Working version

## License

This project is the property of Montserrat Volcano Observatory.
