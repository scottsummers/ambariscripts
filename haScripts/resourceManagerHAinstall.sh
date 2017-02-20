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





echo "This script will install HBase HA using Ambari API calls"
hbaseInstall