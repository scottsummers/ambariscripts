#!/bin/bash

AMBARI_SERVER_HOST="reposerver"
ambariPort="8080"
cluster="HDPCluster"
SERVICE_FILE="services.t"

curlServices(){
	curl --user $username:$PASSWORD \
	     -i -H "X-Requested-By: ambari" \
	     -X POST -d '{"RequestInfo": {"context":"'$context' Service Check from API","command":"'$service'_SERVICE_CHECK"}, "Requests/resource_filters":[{"service_name":"'$context'"}]}' \
	     http://$AMBARI_SERVER_HOST:$ambariPort/api/v1/clusters/$cluster/requests
<<<<<<< Updated upstream
	
=======
>>>>>>> Stashed changes
}

printMenu(){
	lineNum=1
	echo " "
	for i in `cat $SERVICE_FILE`; do
		echo $lineNum $i
	    ((lineNum++))
	done
	echo "$lineNum Run All Service Check" ; ((lineNum++))
	echo "$lineNum (Q)uit"
}


uNamePass(){
	read -p "Ambari Username: " username
	if [ $username == "" ]; then
		exit;
	else	
		read -s -p "Ambari Password: " PASSWORD
	fi
	echo " "
}
runall(){
	context="ZOOKEEPER"; service="ZOOKEEPER_QUORUM"; curlServices
	context="HDFS"; service="HDFS"; curlServices
	context="YARN"; service="YARN"; curlServices
	context="MAPREDUCE2"; service="MAPREDUCE2"; curlServices
	context="HBASE"; service="HBASE"; curlServices
	context="HIVE"; service="HIVE"; curlServices
	context="WEBHCAT"; service="WEBHCAT"; curlServices
	context="OOZIE"; service="OOZIE"; curlServices
}

uNamePass
while true; do
	printMenu
	echo " "
	read -p "Select Service: " value
	case $value in
		1 )  context="ZOOKEEPER"; service="ZOOKEEPER_QUORUM"; curlServices;;
		2 )  context="HDFS"; service="HDFS"; curlServices;;
		3 )  context="YARN"; service="YARN"; curlServices;;
		4 )  context="MAPREDUCE2"; service="MAPREDUCE2"; curlServices;;
		5 )  context="HBASE"; service="HBASE"; curlServices;;
		6 )  context="HIVE"; service="HIVE"; curlServices;;
		7 )  context="WEBHCAT"; service="WEBHCAT"; curlServices;;
		8 )  context="OOZIE"; service="OOZIE"; curlServices;;
		9 )  runall;;
		11|[Qq][Uu][Ii][Tt]|q ) echo "Goodbye!"; exit;;
		* ) echo "Trying Again.";;
	esac
done
