#!/bin/ksh

[ "${1}" == "" ] && echo "please provide a grammar (e.g: ${0} <grammar>)" && exit 1

SENTENCE=""
for i in `cat grammars/${1}/sentence | grammars/${1}/${1} | sed -n -e '/[PARSE|TREE] 2/,/^}/p' | grep "'" | sed -e "s/'//g"`
do 
 SENTENCE="$SENTENCE$i" 
done
echo $SENTENCE
