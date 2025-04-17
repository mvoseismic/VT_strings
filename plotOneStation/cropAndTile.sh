#!/usr/bin/bash
magick mogrify -crop 3769x149+37+37 *.png

magick montage 2*270m27*.png -tile 1x -geometry +0+0 fig-VT_string_montage-270m.png
magick mogrify -bordercolor white -border 200 fig-VT_string_montage-270m*.png

magick montage 2*22m2*.png -tile 1x -geometry +0+0 fig-VT_string_montage-22m.png
magick mogrify -bordercolor white -border 200 fig-VT_string_montage-22m*.png

magick mogrify -resize 25% fig-VT_string_montage*.png
