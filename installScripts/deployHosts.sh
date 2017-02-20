#!/bin/bash

passwordlessSSH() {
  for i in `grep mscottsummers hosts |awk '{ print $1 }'` 
  do
    scp -r -o StrictHostKeyChecking=no sshDir root@$i:~/.ssh/  
  done
}

setupVM(){
  for i in `grep mscottsummers hosts |awk '{ print $1 }'` 
  do
    scp -r -o StrictHostKeyChecking=no VM-set.sh root@$i:~/
    scp -r -o StrictHostKeyChecking=no hosts root@$i:/etc/hosts
    scp -r -o StrictHostKeyChecking=no syncTime.sh root@$i:~/
    scp -r -o StrictHostKeyChecking=no installAmbari200.sh root@$i:~/ 
    ssh root@$i -q "~/VM-set.sh"
  done
}

#passwordlessSSH
setupVM
