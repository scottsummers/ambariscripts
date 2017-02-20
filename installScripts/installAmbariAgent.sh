#!/bin/bash
####
#
#   Install Ambari Agents
#
#
####

ambariServerDNS="reposerver.mscottsummers.com"

for i in `grep mscottsummers /etc/hosts | grep -v "\#" | awk '{ print $2 }'`
do
  echo "Setting up Ambari Agent on : $i" 
  ssh root@$i -q "wget http://public-repo-1.hortonworks.com/ambari/centos6/2.x/updates/2.0.0/ambari.repo; cp ambari.repo /etc/yum.repos.d; rm ambari.repo"
  ssh root@$i -q "yum install -y ambari-agent"
  ssh root@$i -q 'sed -i "s/hostname=localhost/hostname='$ambariServerDNS'/g" /etc/ambari-agent/conf/ambari-agent.ini'
  ssh root@$i -q 'chkconfig ambari-agent on; ambari-agent start'
done
