#!/bin/bash
#
# Download Artworks.json from MoMA's github
FILE=Artworks.json
if [[ -f $FILE ]]; then
    echo "$FILE already exists."
else 
    cd setup/ && { curl -LJO https://github.com/MuseumofModernArt/collection/raw/master/Artworks.json; cd -; } 
fi
