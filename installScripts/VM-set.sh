#!/bin/bash

myHost=`hostname`
ip=`grep $myHost hostsfile | awk '{ print $1 }' `
netmask=255.255.0.0
echo My hosts IP address: $ip

## Setup the network adapter

nic1() {
  grep 'ONBOOT=no' /etc/sysconfig/network-scripts/ifcfg-eth0
  if [ $? -eq 0 ]; then
    sed -i "s/ONBOOT=no/ONBOOT=yes/g" /etc/sysconfig/network-scripts/ifcfg-eth0
  else
    echo "Nothing to Do: ONBOOT set to NO"
  fi
}

nic2() {
  grep 'BOOTPROTO=dhcp' /etc/sysconfig/network-scripts/ifcfg-eth1
  if [ $? -eq 0 ]; then
    sed -i "s/BOOTPROTO=dhcp/BOOTPROTO=none/g" /etc/sysconfig/network-scripts/ifcfg-eth1
  else
    echo "Nothing to Do: BOOTPROTO set to NONE"
  fi
}

#Tuning Options for OS Level
rthKhugepageDefrag() {
  grep "\[yes\]" /sys/kernel/mm/redhat_transparent_hugepage/khugepaged/defrag
  if [ $? -eq 0 ]; then
    echo "Updating Redhat Transparent Hugepage/khugepaged/defrag settings."
    echo no > /sys/kernel/mm/redhat_transparent_hugepage/khugepaged/defrag
    grep "echo no > /sys/kernel/mm/redhat_transparent_hugepage/khugepaged/defrag" /etc/rc.local
    if [ $? -eq 0 ]; then
      echo "echo no > /sys/kernel/mm/redhat_transparent_hugepage/khugepaged/defrag" >> /etc/rc.local
    fi
  else
    echo "Redhat Transparent Hugepage/khugepaged/defrag is already updated."
  fi
}

rthugpage() {
  grep "\[always\]" /sys/kernel/mm/redhat_transparent_hugepage/enabled
  if [ $? -eq 0 ]; then
    echo "Updating Redhat Transparent Hugepage/enabled settings."
    echo never > /sys/kernel/mm/redhat_transparent_hugepage/enabled
    grep "echo never > /sys/kernel/mm/redhat_transparent_hugepage/enabled" /etc/rc.local
    if [ $? -eq 0 ]; then
      echo "echo never > /sys/kernel/mm/redhat_transparent_hugepage/enabled" >> /etc/rc.local
      echo "Added Redhat THP/enabled to rc.local"
    fi
  else
    echo "Redhat Transparent Hugepage/enabled is already updated."
  fi
}

rthDefrag() {
  grep "\[always\]" /sys/kernel/mm/redhat_transparent_hugepage/defrag
  if [ $? -eq 0 ]; then
    echo "Updating Redhat Transparent Hugepage/defrag settings."
    echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag
    grep "echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag" /etc/rc.local
    if [ $? -eq 0 ]; then
      echo "echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag" >> /etc/rc.local
      echo "Added Redhat THP/defrag to rc.local"
    fi
  else
    echo "Redhat Transparent Hugepage/enabled is already updated."
  fi
}

setEth1() {
  grep 'IPADDR=' /etc/sysconfig/network-scripts/ifcfg-eth1
  if [ $? -eq 1 ]; then
    echo "IPADDR=$ip" >> /etc/sysconfig/network-scripts/ifcfg-eth1
    echo "NETMASK=$netmask" >> /etc/sysconfig/network-scripts/ifcfg-eth1
    service network restart
  else
    echo "Network already set."
  fi
}


### Disable SElinux
selinux() {
  grep "SELINUX=enforcing" /etc/selinux/config
  if [ $? -eq 0 ]; then
    setenforce 0
    sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
  else
    echo "SElinux is already disabled"
  fi
}


### install packages

packageCheck() {
 yum -y update
 install=`rpm -qa | egrep "vim|ntp|curl|php_curl|wget" |wc -l`

 if [ $install -eq  8 ]; then
    echo "everything is installed"
 else
    yum -y install scp vim curl php_curl wget ntp unzip
 fi

}

turnoffIPTables() {
  chkconfig iptables off
  /etc/init.d/iptables stop
}

#### Adding hosts to my Host file.
addHostFile() {
  numLine=`wc -l /etc/hosts |awk ' { print $1 } '`
  if [ $numLine -eq 2 ]; then
    cat hostsfile >> /etc/hosts
    echo Just updated Hosts
  else
    echo Hosts file was already updated
    cat /etc/hosts
  fi
}


copySSHKey() {
  if [ `hostname` = "ambari" ]; then
    echo "Can't copy keys to this host"
  else
    scp root@ambari:/root/.ssh/id_rsa* /root/.ssh/
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
  fi
}

kickoffAmbariInstall() {
  if [ `hostname` = "ambari" ]; then
    wget http://public-repo-1.hortonworks.com/ambari/centos6/1.x/updates/1.5.1/ambari.repo
    cp ambari.repo /etc/yum.repos.d
    yum repolist
    yum -y install ambari-server
    ambari-server setup
  else
    echo "I'm not Ambari server"
  fi
}

#### Syncing Time
syncTime() {
  service ntpd stop
  ntpdate 0.pool.ntp.org
  chkconfig ntpd on
  service ntpd start
}

#nic1
#nic2
rthKhugepageDefrag
rthugpage
rthDefrag
#setEth1
selinux
packageCheck
turnoffIPTables
addHostFile
#copySSHKey
#kickoffAmbariInstall
syncTime
