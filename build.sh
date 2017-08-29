#!/bin/bash

OUTNAME="mol.epub"
CURLFLAGS="--compressed"

CHAPTERS=`curl $CURLFLAGS -s https://www.fictionpress.com/s/2961893 | grep -o 'option  value=[0-9]*' | sed 's/^.*value=\([0-9]*\)*[^0-9]*$/\1/' | sort -unr | head -n 1`

echo $CHAPTERS > numchapters

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
		curl $CURLFLAGS -o $filename $url
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

# create cleanmd dir if it doesn't exit
if [[ ! -e cleanmd ]]; then
	mkdir cleanmd
fi

# remove div tags and rewrite chapter tag
for x in `seq $CHAPTERS`
do
    padded=`printf '%03d' $x`
    input="markdown/$x.md"
    output="cleanmd/$padded.md"
    if [[ ! -e $output ]]; then
        echo "cleaning markdown: Chapter $x"
        grep -v '<' $input | sed 's/\*\*\(Chapter [0-9]*\)\*\*/#\1/' > $output
        sed -i 's/- break -/-----/' $output
    fi
done


echo 'building epub...'
pandoc -S -o $OUTNAME title.txt `ls cleanmd/*md | sort -n` --toc

echo 'building mobi...'
kindlegen $OUTNAME
