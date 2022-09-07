#!/usr/bin/env bash

file=$1

rm data/$file

wget -P data/ https://www.ncei.noaa.gov/pub/data/ghcn/daily/$file