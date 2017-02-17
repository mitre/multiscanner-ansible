#!/bin/bash

RESOURCE_DIR=resources
############# ELASTICSEARCH #####################
ELASTICSEARCH_RPM=elasticsearch-5.2.1.rpm
KIBANA_RPM=kibana-5.2.1-x86_64.rpm
ELASTICCO_GPG_KEY=GPG-KEY-elasticsearch
#ELASTICSEARCH_LOCAL_FILE_DIR=roles/elasticsearch/files

# Download ElasticSearch RPM
wget "https://artifacts.elastic.co/downloads/elasticsearch/$ELASTICSEARCH_RPM" --directory-prefix=$RESOURCE_DIR
# Download Kibana RPM
wget "https://artifacts.elastic.co/downloads/kibana/$KIBANA_RPM" --directory-prefix=$RESOURCE_DIR
# Download ES GPG Key
wget "https://artifacts.elastic.co/$ELASTICCO_GPG_KEY" --directory-prefix=$RESOURCE_DIR

#############   RABBITMQ   #####################
RABBITMQ_GPG_KEY=rabbitmq-release-signing-key.asc
# folder in downloads section
RABBITMQ_VERSION=v3.6.6
RABBITMQ_RPM=rabbitmq-server-3.6.6-1.el7.noarch.rpm
#RABBITMQ_LOCAL_FILE_DIR=roles/task_broker/files

# Download RabbitMQ RPM
wget "http://www.rabbitmq.com/releases/rabbitmq-server/$RABBITMQ_VERSION/$RABBITMQ_RPM" --directory-prefix=$RESOURCE_DIR
wget "https://www.rabbitmq.com/$RABBITMQ_GPG_KEY" --directory-prefix=$RESOURCE_DIR
