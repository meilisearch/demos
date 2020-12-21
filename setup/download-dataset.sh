#!/bin/bash
#
# Download Artworks.json from MoMA's github
FILE=Artworks.json
if [ -f "$FILE" ]; then
    echo "$FILE already exists."
else 
    curl -LJO https://github.com/MuseumofModernArt/collection/raw/master/Artworks.json
fi