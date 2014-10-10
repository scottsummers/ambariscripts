#!/bin/bash


haMenu(){
while true; do
	echo "1. - Install HBase HA"
	echo "2. - Install HDFS NN HA"
	echo "3. - Back to Main"
	echo " "
	read -p "Select Service: " value
	case $value in
		1 )  service="HBASE"; hbaseInstall;;
		2 )  service="HDFS"; startService;;
		3 ) break;;
		* ) echo "Trying Again.";;
	esac
done
	
}


hbaseInstall(){
	read -p "What server is do you want HBase Master installed to? " newHbaseMaster
	#Tells Ambari Which Server so install The new HBase Master to
	curl -X POST "http://$AMBARI_SERVER_HOST:$ambariPort/api/v1/clusters/$cluster/hosts?Hosts/host_name=$newHbaseMaster" \
	     -H "X-Requested-By: ambari" \
	     -u $username:$PASSWORD \
	     -d "{\"host_components\" : [{\"HostRoles\":{\"component_name\":\"HBASE_MASTER\"}}] }"
	sleep 5
	#Installs HBase to the New HBASE Master
	service="HBASE"; state='INSTALLED'; action="Installing"; curlServices;
	sleep 20
	curl -X GET "http://$AMBARI_SERVER_HOST:$ambariPort/api/v1/clusters/$cluster/hosts?Hosts/host_name=$newHbaseMaster/" \
	    -u $username:$PASSWORD
	read -p "Would you like to start HBase? " yn
	case $yn in
	  y ) service="GANGLIA"; state="INSTALLED"; action="Restarting"; curlServices; sleep 30;
	      service="GANGLIA"; state="STARTED"; action="Restarting"; curlServices; sleep 30;
	      service="HBASE"; state="STARTED"; action="Starting"; curlServices; break;;
	  n ) echo "Ok, you'll need to start on your own."; break;;
	  * ) break;;
	esac
	
}
