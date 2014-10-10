#!/bin/bash
AMBARI_SERVER_HOST="master01"
ambariPort="8080"
cluster="HDPCluster"
username="admin"
PASSWORD="admin"


curlServices(){
	curl --user $username:$PASSWORD \
	     -i -H "X-Requested-By: ambari" \
	     -X PUT -d '{"RequestInfo": {"context" :"'$action' '$service' via REST"}, "Body": {"ServiceInfo":{"state":"'$state'"}}}' \
	     "http://$AMBARI_SERVER_HOST:$ambariPort/api/v1/clusters/$cluster/services/$service" 
}


hbaseInstall(){
	read -p "What server is do you want HBase Master installed to? " newHbaseMaster
	#Tells Ambari Which Server so install The new HBase Master to
	curl -X POST "http://$AMBARI_SERVER_HOST:$ambariPort/api/v1/clusters/$cluster/hosts?Hosts/host_name=$newHbaseMaster" \
	     -H "X-Requested-By: ambari" \
	     -u $username:$PASSWORD \
	     -d '{"host_components" : [{"HostRoles":{"component_name":"HBASE_MASTER"}}] }'
	sleep 5
	#Installs HBase to the New HBASE Master
	service="HBASE"; state='INSTALLED'; action="Installing"; curlServices;
	echo "Waiting for service to install on servers. Sleeping for 30"
	sleep 30
	curl -u $username:$PASSWORD -X GET "http://$AMBARI_SERVER_HOST:$ambariPort/api/v1/clusters/$cluster/components/$newHbaseMaster/"
	read -p "Would you like to start HBase? " yn
	case $yn in
	  y ) echo "Nagios and Ganglia Configuration need to be changed restarting."
	      service="GANGLIA"; state="INSTALLED"; action="Restarting"; curlServices;
		  service="NAGIOS"; state="INSTALLED"; action="Restarting"; curlServices; sleep 30;
	      service="GANGLIA"; state="STARTED"; action="Restarting"; curlServices;
	      service="NAGIOS"; state="STARTED"; action="Restarting"; curlServices; sleep 30;
	      echo "Ganglia Restarting complete, starting hbase."
	      service="HBASE"; state="STARTED"; action="Starting"; curlServices;;
	  n ) echo "Ok, you'll need to start on your own.";;
	  * ) ;;
	esac
	
}
echo "This script will install HBase HA using Ambari API calls"
hbaseInstall