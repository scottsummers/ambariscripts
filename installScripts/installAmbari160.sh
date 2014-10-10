#!/bin/bash
wget http://public-repo-1.hortonworks.com/ambari/centos6/1.x/updates/1.6.1/ambari.repo
cp ambari.repo /etc/yum.repos.d
rm ambari.repo
yum install -y ambari-server
ambari-server setup -s
ambari-server start

