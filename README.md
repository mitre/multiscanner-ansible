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

### kibana
**Applies to host category**: kibana<br/>
**Expected number of hosts in category**: 1<br/>
**Purpose**:
 * Installs and configures an instance of Kibana
 * Points Kibana to the first host defined in the elasticsearch group

*NOTE:* You can install Kibana on one of the hosts in the elasticsearch group. This role also only exists as a helper feature; it is not required for the operation of MultiScanner and so if you do not want it, simply remove the kibana section from site.yml.

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
### General
Currently, these scripts exclusively support CentOS/RHEL 7 for the managed hosts, and will not work with other operating systems. It is assumed that the managed machines will have access to Yum and pip repositories, but they do not need internet access. The goal is to be able to support (semi) air-gapped environments (after all, this is a malware analysis framework), so as long as the environment has the aforementioned repostitories in some proxied or mirrored form, these scripts will be able to run. Resources that must be obtained from the Internet must be downloaded beforehand into the **resources** folder on the management machine (more on this topic later).

### Hosts
In order to use these Ansible scripts, you need to set up the appropriate machines. You will, of course, need the management machine from which to run Ansible, and then machines for fulfilling the various roles. It is possible to assign multiple roles to one machine; for example, the ReST server and Web UI server roles can be run from one machine, and you would probably want to run Kibana from one of the Elasticsearch hosts. We would recommend that you do not combine any other roles to machines assigned to the ms_worker role or the elasticsearch role (other than adding Kibana to an Elasticsearch host).

In order to allow the management host to communicate with the managed hosts, we recommend creating an Ansible service account on all of the machines, and setting up SSH keys to allow Ansible to communicate without passwords. A guide to setting up SSH keys can be found [here](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2). The service account user will need root access on the managed VMs, and you may want to set up the user to be able to gain root access without a password (otherwise, you will be typing in a password at an obnoxious frequency).

When the mahcines are set up, edit the **hosts** file to assign the machines to the appropriate category(ies). Refer to **site.yml** to see which roles apply to which host categories.

### Internet Resources
Certain resources are not hosted in the standard repositories and so must be downloaded. This should be done on the management machine before trying to run the Ansible plays. The script **download_resources.sh** will download these dependencies to the **resources/** directory, and the Ansible tasks will copy them to the managed systems as necessary. You can change the file versions of the resources in the download script; however, since this will change the file names, you will also need to update the references to the files in the appropriate Ansible files. Comments in the script indicate exactly what will need to be changed for each item.

To run the script, simply run the command `sh download_resources.sh` from the root folder of the project.

### Running the Plays
To run the plays, simply run the command:<br/>
`ansible-playbook -i hosts site.yml`<br/>
from the root folder of the project.

## Scaling
To increase performance/throughput, you might want to add additional hosts (typically worker or Elasticsearch hosts). To do this, simply set up the additional hosts with the appropriate user and SSH keys as described above, and then add their hostnames/IPs to the **hosts** file under the appropriate category.

