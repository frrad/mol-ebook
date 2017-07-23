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

# create markdown dir if it doesn't exit
if [[ ! -e markdown ]]; then
	mkdir markdown
fi

# reformat to markdown
for x in `seq $CHAPTERS`
do
	input="stripped/$x.html"
	output="markdown/$x.md"
    if [[ ! -e $output ]]; then
        echo "converting to markdown: Chapter $x"
        pandoc $input -f html -t markdown -o $output
    fi
done



