#!/bin/sh

GRAMMAR="${1}"
VERSION="${2}"
NO_ITER="${3}"

[ "${GRAMMAR}" == "" ] && echo "provide the grammar (e.g. sql or pascal) to run" && exit 1
[ "${VERSION}" == "" ] && echo "provide the version to run" && exit 1
[ "${3}" == "" ] && echo "provide no of iter's to run" && exit 1

cp grammars/${GRAMMAR}/${GRAMMAR}.${VERSION}.spec grammars/${GRAMMAR}/${GRAMMAR}.spec
ls -la grammars/${GRAMMAR}/${GRAMMAR}.${VERSION}.spec grammars/${GRAMMAR}/${GRAMMAR}.spec
echo "" > grammars/${GRAMMAR}/${GRAMMAR}.${VERSION}.amb_notes

echo "grammar,message,time taken,productions touched factor,iteration count,sentence size,ambiguous sentence size,sub sentence size,parse1 -rules used,parse2"
cnt=0
while [ $cnt -lt "${NO_ITER}" ]
do 
  echo "-- $cnt --" >> grammars/${GRAMMAR}/${GRAMMAR}.${VERSION}.amb_notes
  ./build_lang_grammars test_ambiguity ${GRAMMAR} > grammars/${GRAMMAR}/iter.${NO_ITER}.${cnt}
  egrep '^message' grammars/${GRAMMAR}/iter.${NO_ITER}.${cnt} | awk -F':: ' '{print $2}'
  cp grammars/${GRAMMAR}/sentence grammars/${GRAMMAR}/sentence.${GRAMMAR}
  cnt=`expr $cnt + 1`
done
