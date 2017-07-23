#!/bin/bash

CHAPTERS=72


# create source dir if it doesn't exit
if [[ ! -e source ]]; then
	mkdir source
fi	

# check for undownloaded chapters
for x in `seq $CHAPTERS`
do
	filename="source/$x"
	url="https://www.fictionpress.com/s/2961893/$x"
    if [[ ! -e $filename ]]; then
        echo "Downloading Chapter $x"
		curl -o $filename $url
    fi
done

# create stripped dir if it doesn't exit
if [[ ! -e stripped ]]; then
	mkdir stripped
fi	

# strip headers and footers
for x in `seq $CHAPTERS`
do
	input="source/$x"
	output="stripped/$x.html"
    if [[ ! -e $output ]]; then
        echo "stripping headers/footers: Chapter $x"
        grep "div class='storytext" $input > $output
    fi
done
