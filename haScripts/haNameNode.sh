#!/bin/bash
ambariServer="master01"
ambariUP="admin:admin"
cluster="HDPCluster"



#curl -u admin:admin -i -X POST -d '{"host_components" : [{"HostRoles":{"component_name":"NAMENODE"}}] }' http://<ambari-server-hostname>:8080/api/v1/clusters/c1/hosts?Hosts/host_name=<new-nn-hostname>
curlServices(){
	curl --user $ambariUP \
	     -i -H "X-Requested-By: ambari" \
	     -X PUT -d '{"RequestInfo": {"context" :"'$action' '$service' via REST"}, "Body": {"ServiceInfo":{"state":"'$state'"}}}' \
	     "http://$ambariServer:8080/api/v1/clusters/$cluster/services/$service"
}

getServices(){
   curl -s -X GET "http://$ambariServer:8080/api/v1/clusters/$cluster/services" -u $ambariUP | grep service_name | awk '{ print $3 }' | sed "s/\"//g" > ./"$cluster.Services"
}

stopAll() {
  getServices
  for i in `cat "$cluster.Services"`
  do
   	echo "Stopping $i"
	state='INSTALLED'; action="Stopping"; service=$i; curlServices;
  done;
  rm ./"$cluster.Services"
}

startAll() {
  getServices
  for i in `cat "$cluster.Services"`
  do
   	echo "Starting $i"
	state='STARTED'; action="Starting"; service=$i; curlServices;
  done;
  rm ./"$cluster.Services"
#curl -u admin:admin -i -X POST -d '{"host_components" : [{"HostRoles":{"component_name":"JOURNALNODE"}}] }' http://<ambari-server-hostname>:8080/api/v1/clusters/c1/hosts?Hosts/host_name=<jn1-hostname>
}
startAll
#stopAll