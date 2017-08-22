#!/bin/bash

WORKING_DIR=$(pwd)

# Downloads various RPMs and other resources from the Internet.
# NOTE: if you change the version of any downloaded file, 
# make sure to change the appropriate Ansible variable. The 
# variable and the Ansible file in which it's defined will be noted
# for each filename here in a comment

# ANSIBLE VARIABLE: local_resource_prefix ANSIBLE FILE: group_vars/all
RESOURCE_DIR=resources
rm -rf $RESOURCE_DIR/*

#----------------------- ELASTICSEARCH -----------------------

# ANSIBLE VARIABLE: elasticsearch_rpm ANSIBLE FILE: group_vars/elasticsearch
ELASTICSEARCH_RPM=elasticsearch-5.2.1.rpm

# ANSIBLE VARIABLE: kibana_rpm ANSIBLE FILE: group_vars/elasticsearch
KIBANA_RPM=kibana-5.2.1-x86_64.rpm

# ANSIBLE VARIABLE: elasticco_gpg_key ANSIBLE FILE: group_vars/all
ELASTICCO_GPG_KEY=GPG-KEY-elasticsearch


wget "https://artifacts.elastic.co/downloads/elasticsearch/$ELASTICSEARCH_RPM" --directory-prefix=$RESOURCE_DIR
wget "https://artifacts.elastic.co/downloads/kibana/$KIBANA_RPM" --directory-prefix=$RESOURCE_DIR
wget "https://artifacts.elastic.co/$ELASTICCO_GPG_KEY" --directory-prefix=$RESOURCE_DIR

#----------------------- RABBITMQ -----------------------

# ANSIBLE VARIABLE: rabbit_mq_gpg_key ANSIBLE FILE: group_vars/task_broker
RABBITMQ_GPG_KEY=rabbitmq-release-signing-key.asc

# folder in downloads section
RABBITMQ_VERSION=v3.6.6

# ANSIBLE VARIABLE: rabbit_mq_rpm ANSIBLE FILE: group_vars/task_broker
RABBITMQ_RPM=rabbitmq-server-3.6.6-1.el7.noarch.rpm

wget "http://www.rabbitmq.com/releases/rabbitmq-server/$RABBITMQ_VERSION/$RABBITMQ_RPM" --directory-prefix=$RESOURCE_DIR
wget "https://www.rabbitmq.com/$RABBITMQ_GPG_KEY" --directory-prefix=$RESOURCE_DIR

#----------------------- GLUSTER ----------------------
# ANSIBLE VARIABLE: gluster_version ANSIBLE FILE: group_vars/all
ANSIBLE_VERSION_STR=NORMALIZED

# Install the CentOS Storage repo to download the Gluster RPMs
sudo yum install -y centos-release-gluster

GLUSTER_VERSION=3.10.0
GLUSTER_VERSION_MAJOR_MINOR=3.10
mkdir $RESOURCE_DIR/gluster_server
yumdownloader glusterfs-server --resolve --destdir $RESOURCE_DIR/gluster_server

mkdir $RESOURCE_DIR/gluster_client
yumdownloader glusterfs-client --resolve --destdir $RESOURCE_DIR/gluster_client
# Download the glusterfs-api package for the client
yumdownloader glusterfs-api --resolve --destdir $RESOURCE_DIR/gluster_client

# Rename all the RPMS so that they work with the Ansible installer. Some RPMs will have
# slightly different update version (i.e., 3.10.0 and 3.10.1) but this is not consistent
# and Ansible yum can't handle wildcards 
# SERVER:
SERVER_RPMS=( glusterfs-api- glusterfs-cli-  \
              glusterfs-client-xlators- \
              glusterfs-fuse- glusterfs-libs- glusterfs-server- )
for sr_ in ${SERVER_RPMS[@]}; do    
    mv $RESOURCE_DIR/gluster_server/${sr_}*.rpm $RESOURCE_DIR/gluster_server/${sr_}$ANSIBLE_VERSION_STR.rpm      
done
# main gluster RPM is a special case
mv $RESOURCE_DIR/gluster_server/glusterfs-[0-9]*.rpm $RESOURCE_DIR/gluster_server/glusterfs-$ANSIBLE_VERSION_STR.rpm

# CLIENT:
CLIENT_RPMS=( glusterfs-api- glusterfs-client-xlators- \
              glusterfs-fuse- glusterfs-libs- )
for cr_ in ${CLIENT_RPMS[@]}; do    
    mv $RESOURCE_DIR/gluster_client/${cr_}*.rpm $RESOURCE_DIR/gluster_client/${cr_}$ANSIBLE_VERSION_STR.rpm      
done
# main gluster RPM is a special case
mv $RESOURCE_DIR/gluster_client/glusterfs-$GLUSTER_VERSION_MAJOR_MINOR*.rpm $RESOURCE_DIR/gluster_client/glusterfs-$ANSIBLE_VERSION_STR.rpm

tar -czf $RESOURCE_DIR/gluster_server.tgz -C $RESOURCE_DIR gluster_server
tar -czf $RESOURCE_DIR/gluster_client.tgz -C $RESOURCE_DIR gluster_client

#---------------------- PYTHON 3----------------------
# ANSIBLE VARIABLE: python_version ANSIBLE FILE: group_vars/all
PYTHON_VERSION=3.6.0

wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz --directory-prefix=$RESOURCE_DIR

wget https://bootstrap.pypa.io/get-pip.py --directory-prefix=$RESOURCE_DIR

#---------------------- MULTISCANNER ----------------------
MULTISCANNER_URL="https://github.com/awest1339/multiscanner.git"
MULTISCANNER_BRANCH="celery"

git clone -b $MULTISCANNER_BRANCH $MULTISCANNER_URL $RESOURCE_DIR/multiscanner
tar -czf $RESOURCE_DIR/multiscanner.tgz -C $RESOURCE_DIR multiscanner

#--------------------- Yara Libraries ---------------------
# jansson
wget https://github.com/akheron/jansson/archive/v2.10.tar.gz --directory-prefix=$RESOURCE_DIR
mv $RESOURCE_DIR/v2.10.tar.gz $RESOURCE_DIR/jansson-2.10.tar.gz

# yara
YARA_VER=3.5.0
git clone -b v$YARA_VER https://github.com/VirusTotal/yara-python.git $RESOURCE_DIR/yara-python
cd $RESOURCE_DIR/yara-python
git clone -b v$YARA_VER https://github.com/VirusTotal/yara.git
cd $WORKING_DIR

# clone Androguard Yara module, then copy its modified configs into the yara source...
git clone https://github.com/Koodous/androguard-yara.git $RESOURCE_DIR/androguard-yara
LIBYARA_DIR=$RESOURCE_DIR/yara-python/yara/libyara
cp $RESOURCE_DIR/androguard-yara/androguard.c $LIBYARA_DIR/modules/
cp -f $RESOURCE_DIR/androguard-yara/dist/yara-$YARA_VER/libyara/modules/module_list $LIBYARA_DIR/modules/
cp -f $RESOURCE_DIR/androguard-yara/dist/yara-$YARA_VER/libyara/Makefile.am $LIBYARA_DIR/

# create yara-python.tgz with all the the yara sources to be built on a managed VM
tar -czf $RESOURCE_DIR/yara-python.tgz -C $RESOURCE_DIR yara-python

# yara signatures
git clone --depth 1 https://github.com/Yara-Rules/rules.git $RESOURCE_DIR/Yara-Rules
# Multiscanner's YaraScan module will automatically recurse to find rules in
# subdirectories. Don't need the index files.
rm $RESOURCE_DIR/Yara-Rules/*index.yar
tar -czf $RESOURCE_DIR/Yara-Rules.tgz -C $RESOURCE_DIR Yara-Rules



#----------------------- TrID   --------------------------
curl http://mark0.net/download/trid_linux_64.zip > $RESOURCE_DIR/trid.zip
curl http://mark0.net/download/triddefs.zip > $RESOURCE_DIR/triddefs.zip
