#!/bin/ksh
# create error file when we can't parse
# create memlimit file when RSS for the check ambigiuty program reaches 2GB limit
MAX_MEMLIMIT="`grep MAX_MEMLIMIT HillClimbConfig.rb | sed -e 's/\"//g' | awk -F= '{print $2}'`"
MAX_TIME="`grep MAX_TIME HillClimbConfig.rb | sed -e 's/\"//g' | awk -F= '{print $2}'`"
echo "MAX_MEMLIMIT: ${MAX_MEMLIMIT}, MAX_TIME: ${MAX_TIME}"
LOCK="/logs/lock"
GRAMMAR_FILE="/logs/grammar_file"
while true
do
	# we do anything only if /logs/grammar_file file exists.
	if [ -f "${GRAMMAR_FILE}" ]
	then
		GRAMMAR="`cat ${GRAMMAR_FILE}`"
		if [ -f "${LOCK}" ]
		then
			[ -f grammars/${GRAMMAR}/ambiguous ] && rm grammars/${GRAMMAR}/ambiguous
			# we inspect the first few lines, if ambiguous then we want the whole output
			cat grammars/${GRAMMAR}/sentence | grammars/${GRAMMAR}/${GRAMMAR} | head > grammars/${GRAMMAR}/parse_tree.head
			ERROR="`cat grammars/${GRAMMAR}/parse_tree.head | egrep 'syntax error|illegal token'`"
			if [ ! "$ERROR" == "" ]
			then
				touch grammars/${GRAMMAR}/error
				rm ${LOCK}
				echo "`date` : error while parsing the sentence"
			else
				AMBIGUOUS="`cat grammars/${GRAMMAR}/parse_tree.head | grep 'Grammar ambiguity detected'`"
				if [ ! "${AMBIGUOUS}" == "" ]
				then
					cat grammars/${GRAMMAR}/sentence | grammars/${GRAMMAR}/${GRAMMAR} > /tmp/parse_tree
					cat /tmp/parse_tree | sed -n -e '/PARSE 1\|TREE 1/,/PARSE 2\|TREE 2/p' | egrep -v 'PARSE|TREE|^$|^--|grammar {' | tr -d ' ' | egrep -v '^{|^}' | sed -e "s/'//g" > grammars/${GRAMMAR}/ambiguous_statement
					#head /tmp/parse_tree | grep "^Two different" | sed -e 's/^Two different //' -e "s/'//g" -e 's/`//g' | awk '{print $1}' > grammars/${GRAMMAR}/ambiguous_non_terminal
					AMBIGUOUS_SENTENCE=""
					while read line
					do
					AMBIGUOUS_SENTENCE="$AMBIGUOUS_SENTENCE ${line}"
					done < grammars/${GRAMMAR}/ambiguous_statement
					echo "$AMBIGUOUS_SENTENCE" | tr -d '\n' > grammars/${GRAMMAR}/ambiguous_sub_sentence
					PARSE_TREE1_RULES_USED="`cat /tmp/parse_tree | sed -n -e '/PARSE 1\|TREE 1/,/PARSE 2\|TREE 2/p' | grep 'alternative at line' | sed -e 's/of grammar {//g' -e 's/ alternative at line /,/g' -e 's/ col //g' | tr -d ' ' | sort | uniq | wc -l`"
					PARSE_TREE2_RULES_USED="`cat /tmp/parse_tree | sed -n -e '/PARSE 2\|TREE 2/,/^}\n/p' | grep 'alternative at line' | sed -e 's/of grammar {//g' -e 's/ alternative at line /,/g' -e 's/ col //g' | tr -d ' ' | sort | uniq | wc -l`"
					echo "`wc -c grammars/${GRAMMAR}/ambiguous_sub_sentence | awk '{print $1}'`,${PARSE_TREE1_RULES_USED},${PARSE_TREE2_RULES_USED}" > grammars/${GRAMMAR}/sub_sentence_details
					touch grammars/${GRAMMAR}/ambiguous
					rm ${LOCK}
					echo "[${GRAMMAR}] `date` : ambiguous and removed lock, ${AMBIGUOUS_SENTENCE}"
				else
					rm ${LOCK}
					echo "`date` : removed lock (${LOCK})"
				fi
			fi

		fi
                MAX_MEMLIMIT="`grep MAX_MEMLIMIT HillClimbConfig.rb | sed -e 's/\"//g' | awk -F= '{print $2}'`"
                #echo "MAX_MEMLIMIT: ${MAX_MEMLIMIT}"
		MEMLIMIT="`ps -eo pid,rss,comm | grep checkambiguity | awk '{print $2}'`"
		[ "${MEMLIMIT}" != "" ] && echo "mem: ${MEMLIMIT} KBytes (max: ${MAX_MEMLIMIT})"
		if [ "${MEMLIMIT}" -ge "${MAX_MEMLIMIT}" ]
		then
			touch grammars/${GRAMMAR}/memlimit
			echo "`date` : program reached (${MEMLIMIT} > ${MAX_MEMLIMIT}) memory limit; program will be terminated..."
		fi
	fi

	sleep 1
done
