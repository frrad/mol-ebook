#!/bin/bash

CURLFLAGS="--compressed"
CHAPTERS="108"
OUTPREFIX="mol"
OUTNAME="$OUTPREFIX-$CHAPTERS"
TMP1="/tmp/tmp1"

echo $CHAPTERS > numchapters

# create source dir if it doesn't exit
if [[ ! -e source ]]; then
    mkdir source
fi

# check for undownloaded chapters
for x in `seq $CHAPTERS`
do
    filename="source/$x.html"
    url="https://www.fictionpress.com/s/2961893/$x"
    if [[ ! -e $filename ]]; then
        echo "Downloading Chapter $x"
        curl $CURLFLAGS -o $filename $url
    fi
done

# create markdown dir if it doesn't exit
if [[ ! -e markdown ]]; then
    mkdir markdown
fi

# reformat to markdown
for x in `seq $CHAPTERS`
do
    input="source/$x.html"
    output="markdown/$x.md"
    if [[ ! -e $output ]]; then
        echo "stripping headers/footers: Chapter $x"
        grep "div class='storytext" $input > $TMP1
        echo "converting to markdown: Chapter $x"
        pandoc $TMP1 -f html -t markdown -o $output
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

        #chapter titles
        grep -v '<' $input | sed ':a;N;$!ba;s/\*\*Chapter 0*\([1-9][0-9]*\)\*\*\n\n\*\*\([^\*]*\)\*\*/#\1. \2/g' > $output

        #breaks
        sed -i 's/- break -/-----/' $output

        # reformat
        pandoc $output -o $TMP1
        mv $TMP1 $output
    fi
done

# create cover dir if it doesn't exit
if [[ ! -e cover ]]; then
    mkdir cover
fi
if [[ ! -e cover/raw_cover.jpg ]]; then
    echo "Fetching cover image"
    curl -o cover/raw_cover.jpg http://i.imgur.com/z7W9gc7.jpg
fi
if [[ ! -e cover/cover.jpg ]]; then
    echo "Resizing cover image"
    convert cover/raw_cover.jpg -resize 600x900\! cover/cover.jpg
fi

# Produce epub if current doesn't exist
if [[ ! -e ${OUTNAME}.epub ]]; then
    # ask to remove old ones
    rm -i $OUTPREFIX-*.epub
    echo 'building epub...'
    pandoc -S -o ${OUTNAME}.epub title.txt `ls cleanmd/*md | sort -n` --toc --epub-cover-image=cover/cover.jpg
fi

if [[ ! -e ${OUTNAME}.mobi ]]; then
    rm -i $OUTPREFIX-*.mobi
    echo 'building mobi...'
    kindlegen ${OUTNAME}.epub

    rm -i mobi7-$OUTPREFIX-*.mobi
    echo 'extracting mobi7...'
    # cd .. && git clone https://github.com/kevinhendricks/KindleUnpack.git
    python ../KindleUnpack/lib/kindleunpack.py -s ${OUTNAME}.mobi
    cp ${OUTNAME}/mobi7-${OUTNAME}.mobi .
    rm -rf $OUTNAME
fi

