#!/bin/bash
wget http://public-repo-1.hortonworks.com/ambari/centos6/2.x/updates/2.0.0/ambari.repo
cp ambari.repo /etc/yum.repos.d
rm ambari.repo
yum install -y ambari-server
ambari-server setup -s
ambari-server start

