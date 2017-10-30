#!/bin/bash

# Fetch the variables
. parm.txt

# function to get the current time formatted
currentTime()
{
  date +"%Y-%m-%d %H:%M:%S";
}


sudo docker service scale devops-rocketchat=0
sudo docker service scale devops-rocketchatdb=0

echo ---$(currentTime)---populate the volumes---
#to zip, use: sudo tar zcvf devops_rocketchat_volume.tar.gz /var/nfs/volumes/devops_rocketchat*
sudo tar zxvf devops_rocketchat_volume.tar.gz -C /



echo ---$(currentTime)---create rocketchat database service---
sudo docker service create -d \
--name devops-rocketchatdb \
--mount type=volume,source=devops_rocketchatdb_volume,destination=/data/db,\
volume-driver=local-persist,volume-opt=mountpoint=/var/nfs/volumes/devops_rocketchatdb_volume \
--network $NETWORK_NAME \
--replicas 1 \
--constraint 'node.role == manager' \
$ROCKETCHATDB_IMAGE

echo ---$(currentTime)---create rocketchat service---
sudo docker service create -d \
--publish $ROCKETCHAT_PORT:80 \
--name devops-rocketchat \
--mount type=volume,source=devops_rocketchat_volume_uploads,destination=/app/uploads,\
volume-driver=local-persist,volume-opt=mountpoint=/var/nfs/volumes/devops_rocketchat_volume_uploads \
--network $NETWORK_NAME \
--replicas 1 \
--constraint 'node.role == manager' \
$ROCKETCHAT_IMAGE

sudo docker service scale devops-rocketchatdb=1
sudo docker service scale devops-rocketchat=1
