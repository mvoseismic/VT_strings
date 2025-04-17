#!/usr/bin/bash
getnPlot --source mseed --date 2009-10-05 --time 00:43:46 --dur 120m --pre 10m --tag VT_string --shape xxxlong --kind Z --sta MBRY --env --log   --noscnl --hpfilt 1 --nochaff
getnPlot --source mseed --date 2009-10-07 --time 02:33:47 --dur 120m --pre 10m --tag VT_string --shape xxxlong --kind Z --sta MBRY --env --log   --noscnl --hpfilt 1 --nochaff
getnPlot --source cont --date 2011-03-28 --time 19:05:57 --dur 120m --pre 10m --tag VT_string --shape xxxlong --kind Z --sta MBRY --env --log   --noscnl --hpfilt 1 --nochaff
getnPlot --source cont --date 2012-03-22 --time 20:04:04 --dur 120m --pre 10m --tag VT_string --shape xxxlong --kind Z --sta MBRY --env --log   --noscnl --hpfilt 1 --nochaff
getnPlot --source cont --date 2012-03-23 --time 07:10:14 --dur 120m --pre 10m --tag VT_string --shape xxxlong --kind Z --sta MBRY --env --log   --noscnl --hpfilt 1 --nochaff
getnPlot --source cont --date 2014-03-08 --time 17:51:33 --dur 120m --pre 10m --tag VT_string --shape xxxlong --kind Z --sta MBRY --env --log   --noscnl --hpfilt 1 --nochaff
getnPlot --source cont --date 2014-11-12 --time 05:53:50 --dur 120m --pre 10m --tag VT_string --shape xxxlong --kind Z --sta MBRY --env --log   --noscnl --hpfilt 1 --nochaff
getnPlot --source cont --date 2015-12-25 --time 01:12:57 --dur 120m --pre 10m --tag VT_string --shape xxxlong --kind Z --sta MBRY --env --log   --noscnl --hpfilt 1 --nochaff
getnPlot --source cont --date 2017-07-27 --time 10:40:17 --dur 120m --pre 10m --tag VT_string --shape xxxlong --kind Z --sta MBRY --env --log   --noscnl --hpfilt 1 --nochaff
getnPlot --source cont --date 2019-04-10 --time 22:03:23 --dur 120m --pre 10m --tag VT_string --shape xxxlong --kind Z --sta MBRY --env --log   --noscnl --hpfilt 1 --nochaff
getnPlot --source cont --date 2020-02-05 --time 14:55:57 --dur 120m --pre 10m --tag VT_string --shape xxxlong --kind Z --sta MBRY --env --log   --noscnl --hpfilt 1 --nochaff
getnPlot --source mseed --date 2020-12-31 --time 03:57:34 --dur 120m --pre 10m --tag VT_string --shape xxxlong --kind Z --sta MBRY --env --log   --noscnl --hpfilt 1 --nochaff
getnPlot --source mseed --date 2021-02-20 --time 21:09:09 --dur 120m --pre 10m --tag VT_string --shape xxxlong --kind Z --sta MBRY --env --log   --noscnl --hpfilt 1 --nochaff
getnPlot --source mseed --date 2022-02-17 --time 11:34:01 --dur 120m --pre 10m --tag VT_string --shape xxxlong --kind Z --sta MBRY --env --log   --noscnl --hpfilt 1 --nochaff
getnPlot --source mseed --date 2022-07-30 --time 15:52:07 --dur 120m --pre 10m --tag VT_string --shape xxxlong --kind Z --sta MBRY --env --log   --noscnl --hpfilt 1 --nochaff
getnPlot --source mseed --date 2023-07-07 --time 08:06:48 --dur 120m --pre 10m --tag VT_string --shape xxxlong --kind Z --sta MBRY --env --log   --noscnl --hpfilt 1 --nochaff
getnPlot --source mseed --date 2023-10-20 --time 14:48:20 --dur 120m --pre 10m --tag VT_string --shape xxxlong --kind Z --sta MBRY --env --log   --noscnl --hpfilt 1 --nochaff
getnPlot --source mseed --date 2023-11-04 --time 23:08:54 --dur 120m --pre 10m --tag VT_string --shape xxxlong --kind Z --sta MBRY --env --log   --noscnl --hpfilt 1 --nochaff
getnPlot --source mseed --date 2023-12-29 --time 17:03:34 --dur 120m --pre 10m --tag VT_string --shape xxxlong --kind Z --sta MBRY --env --log   --noscnl --hpfilt 1 --nochaff
getnPlot --source mseed --date 2024-04-29 --time 13:43:42 --dur 120m --pre 10m --tag VT_string --shape xxxlong --kind Z --sta MBRY --env --log   --noscnl --hpfilt 1 --nochaff
getnPlot --source mseed --date 2024-12-19 --time 14:20:39 --dur 120m --pre 10m --tag VT_string --shape xxxlong --kind Z --sta MBRY --env --log   --noscnl --hpfilt 1 --nochaff

magick mogrify -crop 1798x152+82+62 2*.png
magick montage 2*.png -tile 1x -geometry +0+0 fig-VT_string_montage-120m.png
magick mogrify -bordercolor white -border 200 fig-VT_string_montage-120m*.png

