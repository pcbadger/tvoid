#!/bin/sh
TMP=OUTPUT/tmp
OUTPUT=OUTPUT/out.txt
SYNOPSIS=OUTPUT/synopsis.txt
TITLE=OUTPUT/title.txt
TITLE_PREFIX=OUTPUT/title_prefix.txt
TITLE_SUFFIX=OUTPUT/title_suffix.txt
echo "clearing old files"
rm -rf  ${TMP} ${OUTPUT} ${SYNOPSIS} ${TITLE} ${TITLE_PREFIX} ${TITLE_SUFFIX}
iconv -c -f UTF-8 -t US-ASCII//TRANSLIT INPUT/* | sort | uniq >> ${TMP}
#iconv -c -f UTF-8 -t US-ASCII//TRANSLIT ${TMP} >> 

echo "tidying big file"
# Removing stuff that isn't a title or synops
gsed -i -E '/(Location|Enemy|Enemies|Earth date):/d' ${TMP}
gsed -i -E "/([A-Z]|[a-z])/!d" ${TMP}
gsed -i -E "s/(\([0-9]\))//g" ${TMP}
gsed -i -E "/^(Season|Episode)\ [0-9]/d" ${TMP}
gsed -i -E "s/(MORE|LESS)//g" ${TMP}

# standardising stardates
gsed -i  -E "s/Stardate(:|\,)(\ |)(([0-9]+(\.[0-9]+|))|Unknown)/Stardate- Unknown/g" ${TMP}
gsed -i 's/: /, /g' ${TMP}
gsed -i 's/Stardate- Unknown/Stardate: Unknown/g' ${TMP}

# converting quotes
gsed -i -E 's/(“|”|‘|’|")/ /g' ${TMP}
gsed -i -E "s/(\ \'|\'\ )/ /g" ${TMP}

# gsed -i "s/â€™/\'/g" ${TMP}
# gsed -i "s/â€¦/\./g" ${TMP}
# gsed -i "s/…/\./g" ${TMP}
# Removing stray .
gsed -i "s/a\.k\.a\./A.K.A./g" ${TMP}
gsed -i 's/Mrs\./Mrs/g' ${TMP}
gsed -i -E 's/(\ v\.|\ vs\.)/ VS/g' ${TMP}
gsed -i 's/Mr\./Mr/g' ${TMP}
gsed -i 's/Ms\./Miss/g' ${TMP}
gsed -i -E 's/Dr(\.| )/Doctor/g' ${TMP}
gsed -i 's/Lt\./Lt/g' ${TMP}
gsed -i 's/Cmdr\./Commander/g' ${TMP}
gsed -i 's/Capt\./Captain/g' ${TMP}

# Homogenising punctuation
gsed -i 's/;/. /g' ${TMP}
gsed -i 's/ (/, /g' ${TMP}
gsed -i 's/)//g' ${TMP}
gsed -i -E 's/(---|--|- | -)/, /g' ${TMP}
gsed -i 's/\.\.\./, /g' ${TMP}
gsed -i 's/ , /, /g' ${TMP}
gsed -i 's/  / /g' ${TMP}
gsed -i 's/  / /g' ${TMP}
gsed -i 's/  / /g' ${TMP}
gsed -i 's/  / /g' ${TMP}
# Splitting synops into individual sentences
gsed -i -E 's/([a-z])\./\1\.\n/g' ${TMP}
# Deleting leading and trailing whitespace
gsed -i -E "s/^(\ )//g" ${TMP}
gsed -i -E "s/(\ )$//g" ${TMP}


cat ${TMP} | awk '{ print length, $0 }' | sort -n -s | uniq | cut -d" " -f2- >> ${OUTPUT}

echo "sorting titles and synopses"
while read LINE ; do
  # Split line into array
	IFS=' ' read -r -a WORDS <<< ${LINE}
  PATTERN1="([a-z]+)"
  PATTERN2="([A-Z][a-zA-Z]*)"
  LOWERCASE_PRESENT="false"

	for ONE_WORD in ${WORDS[@]}; do
      # if a word hase lowercase letters and isn't Titlecase
	    if [[ ${ONE_WORD} =~ ${PATTERN1} ]] && ! [[ ${ONE_WORD} =~ ${PATTERN2} ]]; then
        # and it's not one of these words
	       if ! [[ ${ONE_WORD} =~ ^(of|in|at|the|to|for|on|and|a|it|is|an|from|with|over|under|by|vs|as|but|or)$ ]]; then
              # It's probably a tile
              LOWERCASE_PRESENT="true"
              break
           fi
	    fi
	done
	if [[ ${LOWERCASE_PRESENT} == "true" ]]; then
		echo ${LINE} >> ${SYNOPSIS}
	else
	  echo ${LINE} >> ${TITLE}
	fi
done < ${OUTPUT}
#set -x

echo "splitting up titles"
while read TITLES ; do
  WORD_COUNT=`echo "${TITLES}" | wc -w`
  if [[ ${TITLES} =~ [A-Za-z] ]]; then
    if [[ ${WORD_COUNT} =~ "1" ]]; then
      echo ${TITLES} >> ${TITLE_PREFIX}
    else
      let "MID = ${WORD_COUNT} / 2"
      MID=`echo ${MID} | awk '{print int($1+0.5)}'`
      if [[ ${MID} == 0 ]]; then
     	  MID=1
      fi
      PREFIX=`echo "${TITLES}" | cut -d " " -f -${MID}`
      SUFFIX=`echo "${TITLES}" | cut -d " " -f $((${MID}+1))-`
      echo ${PREFIX} >> ${TITLE_PREFIX}
      if [[ ${PREFIX} != ${SUFFIX} ]]; then
        if [[ ! -z ${SUFFIX} ]]; then
          echo ${SUFFIX} >> ${TITLE_SUFFIX}
        fi
      fi
    fi
  fi
done < ${TITLE}	
rm -rf ${TMP} ${OUTPUT}