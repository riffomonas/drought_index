#!/usr/bin/env bash

mkdir -p map_tempdir

git log --pretty=format:"%h %ai %s" --after "2022-11-07 12:00:00" visuals/world_drought.png |
  while read h; do
    HASH=`echo $h | sed "s/^\(.*\) 20..-.*/\1/"`
    DATE=`echo $h | sed "s/.* \(20..-..-..\) .*/\1/"`
    git cat-file -p ${HASH}:visuals/world_drought.png > map_tempdir/${DATE}.png
    echo $DATE
  done

convert -delay 20 map_tempdir/*png visuals/world_drought.gif

rm -rf map_tempdir