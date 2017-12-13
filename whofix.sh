#!/bin/sh
INPUT=WHOINPUT/*
TMP=OUTPUT/whotmp
OUTPUT=OUTPUT/whoout.txt
SYNOPSIS=OUTPUT/whosynopsis.txt
TITLE=OUTPUT/whotitle.txt

rm -rf  ${TMP} ${OUTPUT} ${SYNOPSIS} ${TITLE} ${TITLE_PREFIX} ${TITLE_SUFFIX}


cat ${INPUT} | grep description | cut -d \> -f 2- | rev | cut -d \< -f 2- | rev | gsed -E "s/<(\/|)p>//g" | gsed -e 's/([^()]*)//g' | sort | uniq >> ${TMP}

cat ${INPUT} | grep 'span class="_more">more</span>' | gsed 's/<\/span.*//g' | gsed 's/<span class="_hidden">&nbsp;/ /g' | gsed -E "s/<(\/|)p>//g" | gsed -e 's/([^()]*)//g' | sort | uniq >> ${TMP}

cat ${INPUT} | grep 'a class="title"href=' | cut -d \> -f 2 | gsed 's/<\/a//g' >> ${TITLE}