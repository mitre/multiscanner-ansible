# multiscanner-ansible
Ansible configurations for distributed MultiScanner installations (WORK IN PROGRESS)

## Purpose
This project exists to facilitate configuring the [MultiScanner](https://github.com/MITRECND/multiscanner) file analysis framework in a distributed setting. It defines [Ansible](https://www.ansible.com/get-started) configurations to enable automated configuration management of machines in a MultiScanner setup. 

## MultiScanner Distributed Setup
Distributed MultiScanner (as you would expect) makes use of applications running on several machines. There is a web server (role: webserver) that hosts the web UI and ReSTful services to provide a single point for user interaction. As files are submitted through the web UI or ReST services, they are stored to a distributed file system (DFS) and tasks are created. The tasks are logged to a database (role: task_db) for tracking purposes, and then sent via Celery through a RabbitMQ message broker (role: task_broker) to worker nodes. The worker nodes (role: ms_worker) fetch the file(s) specified in the task from the DFS and process them in MultiScanner. When processing completes, the worker nodes post the analysis results to the Elasticsearch data store (role: elasticsearch) and update the task status in the task tracker database. Then the user can access the reports from the data store. 


## Roles
This section describes the Ansible roles. Each role has its own folder under **roles/**, and defines tasks to be executed for all hosts in the category(ies) associated with that role. The host categories are established in the **hosts** file, and the association of host categories to roles is established in **site.yml**. 

### common
**Applies to host category**: all<br/>
**Purpose**: Establishes settings common to all machines in the setup, such as setting up the "multiscanner" user that will be used to run various tasks and services.

### webserver
**Applies to host category**: webserver<br/>
**Expected number of hosts in category**: 1<br/>
**Purpose**:
 * Installs and configures the web server for hosting the MultiScanner UI
 * Installs and configures the central instance of MultiScanner, which will use Celery to distribute tasks to MultiScanner instances on the worker nodes. 

### ms_worker
**Applies to host category**: ms_worker<br/>
**Expected number of hosts in category**: 1 - many<br/>
**Purpose**:
 * Installs and configures an instance of MultiScanner 
 
### elasticsearch
**Applies to host category**: elasticsearch<br/>
**Expected number of hosts in category**: 1 - many<br/>
**Purpose**:
 * Installs and configures an instance of Elasticsearch
 * Joins Elasticsearch instance to a cluster

### task_broker
**Applies to host category**: task_broker<br/>
**Expected number of hosts in category**: 1<br/> 
**Purpose**:
 * Installs and configures RabbitMQ Server, including the management plugin
 
### task_db
**Applies to host category**: task_db<br/>
**Expected number of hosts in category**: 1<br/>
**Purpose**:
 * Installs and configures a PostgreSQL database
 


## Setup
TODO - describe process of setting up VMs, generating SSH keys, and other basic Ansible things

## Scaling
TODO - describe reasons for adding new machines (ES nodes, worker nodes)
TODO - describe process for adding new nodes (create VM, update config files to include new IP/hostname, etc)

