#!/bin/ksh
# This script will display the two parse tree along with the ambiguous sub-sentence

GRAMMAR="${1}"

[ "${GRAMMAR}" == "" ] && echo "please provide a grammar" && exit 1

[ -f grammars/${GRAMMAR}/sentence ] && [ -f grammars/${GRAMMAR}/${GRAMMAR} ] && cat grammars/${GRAMMAR}/sentence | grammars/${GRAMMAR}/${GRAMMAR} > grammars/${GRAMMAR}/parse_trees

cat grammars/${GRAMMAR}/parse_trees | sed -n -e '/PARSE 1\|TREE 1/,/PARSE 2\|TREE 2/p' | egrep -v 'PARSE|TREE|^$' > grammars/${GRAMMAR}/tree_1

#cat parse_trees | sed -n -e '/PARSE 2\|TREE 2/,/^}\n/p' | egrep -v 'PARSE|TREE|^$' > tree_2
cat grammars/${GRAMMAR}/parse_trees | sed -n -e '/PARSE 2\|TREE 2/,/^}\n/p' | egrep -v '^use %|^For ``Subphrase|^END OF GRAMMAR|^line ' | egrep -v 'PARSE|TREE|^$' > grammars/${GRAMMAR}/tree_2

cat grammars/${GRAMMAR}/parse_trees | sed -n -e '/PARSE 1\|TREE 1/,/PARSE 2\|TREE 2/p' | egrep -v 'PARSE|TREE|^$|^--|grammar {' | tr -d ' ' | egrep -v '^{|^}' > grammars/${GRAMMAR}/ambiguous_statement

SENTENCE=""

while read line 
do 
  SENTENCE="$SENTENCE $line"
done < grammars/${GRAMMAR}/ambiguous_statement

echo "AMBIGIUOUS PART: $SENTENCE"

sdiff -w 160 grammars/${GRAMMAR}/tree_1 grammars/${GRAMMAR}/tree_2


