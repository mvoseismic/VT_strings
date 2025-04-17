# joinhelis

Create montages of helicorder plots.

## joinhelis.pl

* Creates multi-station montages for one day.
* Run daily as a cron job under user *mvo* on *winston1*.

### Usage

*joinhelis.pl \<--stagrp\> \<--datebeg\> \<--dateend\> *

* --stagrp: stations to montage (see code for options).

## heliStackMonths.pl, heliStack.pl

* Scripts to create multi-day, multi-station montages of helicorders.
* Superceded by *heliStackWide*.

## oneStationMonthAll.sh

* Script to run *oneStationMonth.pl* for each station in a loop of dates.
* Used to catch up missing plots.

## oneStationMonth.pl

* Creates a montage of one month's helicorder plots for one station.
* Saves plot in */mnt/mvofls2/Seismic_Data/monitoring_data/helicorder_plots_station_month*.

### Usage

*oneStationMonth.pl \<station code\> \<month\> \<year\>*

## oneStationMonthThis.sh

* Runs *oneStationMonth.pl* for each station.
* Run daily as a cron job on *opsproc3*.

## Author

Roderick Stewart, Dormant Services Ltd

rod@dormant.org

https://services.dormant.org/

## Version History

* 1.0-dev
    * Working version

## License

This project is the property of Montserrat Volcano Observatory.
