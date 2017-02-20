#!/bin/bash
#pdsh -g hdp "service ntpd stop; ntpdate 0.pool.ntp.org; service ntpd start" | dshbak
#pdsh -g hdp "date" | dshbak


for i in `grep mscottsummers /etc/hosts | grep -v "\#" | awk '{ print $2 }'` 
do 
	ssh root@$i -q "reboot"
done

#for i in `grep mscottsummers /etc/hosts | grep -v "\#" | awk '{ print $2 }'` 
#do 
#	ssh root@$i -q "hostname; date"
#done
