#echo "starting checkamb.sh script ..."
#./checkamb.sh &
#echo "checkamb.sh in the bg!"
#ps -eo pid,comm,args | grep checkamb.sh | grep -v grep | awk '{print $1}'

for GRAMMAR in `cat x` 
do 
        echo $GRAMMAR
	./build test_ambiguity ${GRAMMAR} > grammars/${GRAMMAR}/log 
        grep ^message grammars/${GRAMMAR}/log | awk -F':: ' '{print $2}'
done
