#!/bin/bash

AMBARI_SERVER_HOST="master01"
ambariPort="8080"
SERVICE_FILE="services"
cluster="HDPCluster"

curlServices(){
	curl -s --user $username:$PASSWORD -i -H "X-Requested-By: ambari" \
	     -X PUT -d '{"RequestInfo": {"context" :"'$action' '$service' via REST"}, "Body": {"ServiceInfo":{"state":"'$state'"}}}' \
	     "http://$AMBARI_SERVER_HOST:$ambariPort/api/v1/clusters/$cluster/services/$service" | grep '"id"' | awk '{ print $3 }' | sed "s/,//g"
}

restartService(){
	state='INSTALLED'
	action="Stopping"
	curl -s --user $username:$PASSWORD -i -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo": {"context" :"'$action' '$service' via REST"}, "Body": {"ServiceInfo":{"state":"'$state'"}}}' "http://$AMBARI_SERVER_HOST:$ambariPort/api/v1/clusters/$cluster/services/$service" | grep '"id"' | awk '{ print $3 }' | sed "s/,//g"
	requestId=$?
	echo "Request ID = " $requestId
	
	
}

stopHostService(){
	#curl -u admin:$PASSWORD -i -H 'X-Requested-By: ambari' -X PUT -d '{"RequestInfo": {"context" :"Stop HDFS via REST"}, "Body": {"ServiceInfo": {"state": "INSTALLED"}}}' http://AMBARI_SERVER_HOST:8080/api/v1/clusters/CLUSTER_NAME/services/HDFS
#	curl -s --user admin:admin -i -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo": {"context" :"Stop HDFS via REST"}, "Body": {"ServiceInfo": {"state": "INSTALLED"}}}' http://ambari.mscottsummers.com:8080/api/v1/clusters/hdpcluster/hosts/slave02.mscottsummers.com/host_components/DATANODE
}

startServiceMenu(){
	echo " "
	echo "What action to perform on $service? "
	echo " 1. Start "
	echo " 2. Stop "
	echo " 3. Restart "
	echo " 4. Back "
	echo " "
}

startService(){
	while true; do
		startServiceMenu
	    read -p "Select > " number
	    case $number in
	        1 ) state='STARTED'; action="Starting"; curlServices; break;;
	        2 ) state='INSTALLED'; action="Stopping"; curlServices; break;;
				 3 ) restartService; break;;
			4 ) break;;
	        * ) echo "Trying Again.";;
	    esac
	done
}

printMenu(){
	lineNum=1
	echo " "
	for i in `cat $SERVICE_FILE`; do
		echo $lineNum $i
	    ((lineNum++))
	done
	echo "$lineNum Start All Services" ; ((lineNum++))
	echo "$lineNum Stop All Services" ; ((lineNum++))
	echo "$lineNum (Q)uit"
}

uNamePass(){
	read -p "Ambari Username: " -t 5 username
	if [ $username == "" ]; then
		exit;
	else	
		read -s -p "Ambari Password: " PASSWORD
	fi
	echo " "
}

startAll(){
	for i in `cat $SERVICE_FILE`; do
		echo "Starting $i"
		state='STARTED'; action="Starting"; service=$i; curlServices;
	done
	echo "Cluster is Starting..."
}

stopAll(){
	for i in `tail -r $SERVICE_FILE`; do
		echo "Stopping $i"
		state='INSTALLED'; action="Stopping"; service=$i; curlServices;
	done
	echo "Cluster is Stopping..."
}

menuCase(){
	while true; do
		printMenu
		echo " "
		read -p "Select Service: " value
		case $value in
			1 )  service="ZOOKEEPER"; startService;;
			2 )  service="HDFS"; startService;;
			3 )  service="YARN"; startService;;
			4 )  service="MAPREDUCE2"; startService;;
			5 )  service="HBASE"; startService;;
			6 )  service="HIVE"; startService;;
			7 )  service="WEBHCAT"; startService;;
			8 )  service="OOZIE"; startService;;
			9 )  service="GANGLIA"; startService;;
			10 ) service="NAGIOS"; startService;;
			11 ) startAll;;
			12 ) stopAll;;
			13|[Qq][Uu][Ii][Tt]|q ) echo "Goodbye!"; exit;;
			* ) echo "Trying Again.";;
		esac
	done
}


uNamePass
menuCase
