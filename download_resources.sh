#!/bin/bash

# Downloads various RPMs and other resources from the Internet.
# NOTE: if you change the version of any downloaded file, 
# make sure to change the appropriate Ansible variable. The 
# variable and the Ansible file in which it's defined will be noted
# for each filename here in a comment

# ANSIBLE VARIABLE: local_resource_prefix ANSIBLE FILE: group_vars/all
RESOURCE_DIR=resources

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

#----------------------- LIQUIBASE ----------------------
PGSQL_JDBC_DRIVER=postgresql-42.0.0.jar
LIQUIBASE_VERSION=3.5.3

wget https://jdbc.postgresql.org/download/$PGSQL_JDBC_DRIVER --directory-prefix=$RESOURCE_DIR
wget https://github.com/liquibase/liquibase/releases/download/liquibase-parent-$LIQUIBASE_VERSION/liquibase-$LIQUIBASE_VERSION-bin.tar.gz --directory-prefix=$RESOURCE_DIR
