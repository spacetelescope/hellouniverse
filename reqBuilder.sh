#!/bin/bash

echo Parsing requirements from ./notebooks
find ./notebooks -name "*.ipynb" | xargs -I {} pipreqsnb {} > /dev/null 2>&1
find ./notebooks -iname "requirements.txt" -print0 | xargs -0 -I {} cat {} >> reqList.txt
cat reqList.txt | cut -f1 -d"=" | sort -u > reqList2.txt
ureqs=`cat reqList2.txt | wc -l`
echo Done: Requirements file built with $ureqs unique requirements: reqsList2.txt
