#!/bin/bash
#
# Download Artworks.json from MoMA's github
if [ -s Artworks ]
then
curl -LJO https://github.com/MuseumofModernArt/collection/raw/master/Artworks.json
else
echo "File already exists"
fi