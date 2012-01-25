#!/bin/sh

[ "${1}" == "" ] && echo "provide a grammar to parse" && exit 1
[ "${2}" == "" ] && echo "provide a file to parse" && exit 1

#cat grammars/${1}/${2} | grep  -v '^message: ambi' > grammars/${1}/${2}.1

echo "Ambiguous, Time taken, Iteration, Productions touched (factor), sentence size"

while read line
do 
	no_line="`echo $line | cut -c1,2`"
	#echo "$line"
	#echo "** $no_line, $amb_line"
	if [ "$no_line" == "--" ]
	then 
		no="`echo $line | awk '{print $2}'`"
	else
		message="`echo $line | awk '{print $1}' | sed -e 's/://'`"
		if [ "${message}" == "message" ]
		then
			#split the line by ","
			MESSAGE="`echo ${line} | awk -F, '{print $1}' | awk -F: '{print $2}'`"
			TIME_TAKEN="`echo ${line} | awk -F, '{print $2}' | awk -F: '{print $2}'`"
			ITERATION="`echo ${line} | awk -F, '{print $3}' | awk -F: '{print $2}'`"
			PRODUCTIONS_TOUCHED="`echo ${line} | awk -F, '{print $4}' | awk -F: '{print $2}'`"
			SENTENCE_SIZE="`echo ${line} | awk -F, '{print $5}' | awk -F: '{print $2}'`"
			echo "${MESSAGE}, ${TIME_TAKEN}, ${ITERATION}, ${PRODUCTIONS_TOUCHED}, ${SENTENCE_SIZE}"
		fi
	fi
	no_line=""
	amb_line=""
done <  grammars/${1}/${2}
