#!/bin/bash
wc -c -m -l -L -w cleanmd/* | tr -s ' ' ',' | head -n -1 | cut -c 2- > stats/data.csv
