#!/usr/bin/env bash

tar Oxvzf data/ghcnd_all.tar.gz | grep "PRCP" | gzip > data/ghcnd_cat.fwf.gz
