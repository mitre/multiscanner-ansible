# multiscanner-ansible
Ansible configurations for distributed MultiScanner installations.

## Purpose
This project exists to facilitate configuring the [MultiScanner](https://github.com/MITRECND/multiscanner) file analysis framework in a distributed setting. It defines [Ansible](https://www.ansible.com/get-started) configurations to enable automated configuration management of machines in a MultiScanner setup. 


## MultiScanner Distributed Setup
Distributed MultiScanner (as you would expect) makes use of applications running on several machines. There is a web server (role: webserver) that hosts the web UI and ReSTful services to provide a single point for user interaction. As files are submitted through the web UI or ReST services, they are stored to a distributed file system (DFS) and tasks are created. The tasks are logged to a database (role: task_db) for tracking purposes, and then sent via Celery through a RabbitMQ message broker (role: task_broker) to worker nodes. The worker nodes (role: ms_worker) fetch the file(s) specified in the task from the DFS and process them in MultiScanner. When processing completes, the worker nodes post the analysis results to the Elasticsearch data store (role: elasticsearch) and update the task status in the task tracker database. Then the user can access the reports from the data store. 


## Roles
This section describes the Ansible roles. Each role has its own folder under **roles/**, and defines tasks to be executed for all hosts in the category(ies) associated with that role.  

### common
**Applies to host category**: all<br/>
**Purpose**: 
 * Establishes settings common to all machines in the setup, such as setting up the "multiscanner" user that will be used to run various tasks and services.

### apache
**Applies to host category**: restserver, webserver<br/>
**Purpose**:
 * Installs and configures the Apache web server
 
### ms_common
**Applies to host category**: ms_worker, restserver, webserver<br/>
**Purpose**:
 * Installs and configures an instance of MultiScanner

### apache
**Applies to host category**: restserver, webserver<br/>
**Purpose**:
 * Installs and configures an instance of Apache
 
### ms_webserver
**Applies to host category**: webserver<br/>
**Purpose**:
 * Installs and configures the web server for hosting the MultiScanner UI. Note: requires the **ms_common** role to
 be run first (make sure to place it AFTER the ms_common role in the playbook)
 
### ms_restserver
**Applies to host category**: restserver<br/>
**Purpose**:
 * Installs and configures the Multiscanner REST server. * Installs and configures the web server for hosting the MultiScanner UI. Note: requires the **ms_common** role to
 be run first (make sure to place it AFTER the ms_common role in the playbook) 

### ms_worker
**Applies to host category**: ms_worker<br/>
**Purpose**:
 * Installs and configures the MultiScanner Celery Worker service
 
### elasticsearch
**Applies to host category**: elasticsearch<br/>
**Purpose**:
 * Installs and configures an instance of Elasticsearch
 * Joins Elasticsearch instance to a cluster

### kibana
**Applies to host category**: kibana<br/>
**Purpose**:
 * Installs and configures an instance of Kibana
 * Points Kibana to the first host defined in the elasticsearch group

### task_broker
**Applies to host category**: task_broker<br/>
**Purpose**:
 * Installs and configures RabbitMQ Server, including the management plugin
 
### task_db
**Applies to host category**: task_db<br/>
**Purpose**:
 * Installs and configures a PostgreSQL database
 
### dfs_server
**Applies to host category**: dfs_server<br/>
**Purpose**:
 * Installs Gluster FS
 * Creates a Gluster shared volume
 
### dfs_client
**Applies to host category**: ms_worker, webserver, restserver<br/>
**Purpose**:
 * Mounts the shared Gluster FS volume

### python3
**Applies to host category**: ms_worker, webserver, restserver<br/>
**Purpose**:
 * Installs Python 3 from source
 * Installs pip and virtualenv
 * Sets Python 3 and its associated pip and virtualenv as the system defaults

## Host Categories
This section describes the host categories. The host categories are defined and mapped to actual hostnames/IPs in the **hosts** file, and the association of host categories to roles is defined in **site.yml**.

### webserver
**Required number of hosts in category**: 1<br/>
Hosts the Multiscanner web service.  

### restserver
**Required number of hosts in category**: 1<br/>
Hosts the Multiscanner REST service. The host assigned to this category can be the same as the host assigned to the **webserver** category.

### task_broker
**Required number of hosts in category**: 1<br/>
Hosts the RabbitMQ message server for queueing/distributing tasks.

### elasticsearch
**Required number of hosts in category**: 1 - many<br/>
These hosts define the Elasticsearch cluster for storing reports. We recommend specifying at least 2 hosts.

### kibana
**Required number of hosts in category**: 0 - many<br/>
Hosts an instance of Kibana. This is optional; if you don't want to install Kibana, remove this section from the **hosts** file and remove the **kibana** section from **site.yml**. It is perfectly acceptable to assign one or more of the hosts from the **elasticsearch** category to this category.

### task_db
**Required number of hosts in category**: 1<br/>
Hosts the PostgreSQL database for storing task information.

### ms_worker
**Required number of hosts in category**: 1 - many<br/>
Hosts the Multiscanner Celery Worker service. To achieve the maximum benefit of using MultiScanner's distributed feature, 
we recommend adding at least 2 hosts to this category. Furthermore, to maximize speed of file storage and
retrieval, we recommend listing the hosts in this category in the dfs_server category as well (just be sure
to adhere to the requirements for the number of hosts in the dfs_server category, see below).

### dfs_server
**Required number of hosts in category**: 2 - many<br/>
Hosts the Gluster shared volume for submitted file storage. Note that a minimum of 2 hosts is required; add more hosts for better redundancy. 
*The number of hosts must be a multiple of the number of replicas defined in the `dfs_replica_count` variable
in **group_vars/dfs_server**!*


## Setup
### General
Currently, these scripts exclusively support CentOS/RHEL 7 for the managed hosts, and will not work with other operating systems. It is assumed that the managed machines will have access to Yum and pip repositories, but they do not need internet access. The goal is to be able to support (semi) air-gapped environments (after all, this is a malware analysis framework), so if the environment has the aforementioned repositories in some proxied or mirrored form, these scripts will be able to run. Resources that must be obtained from the Internet must be downloaded beforehand into the **resources** folder on the management machine (more on this topic later).

### Hosts
In order to use these Ansible scripts, you need to set up the appropriate machines. You will need the management machine from which to run Ansible (referred to as the Ansible Controller), and then machines for fulfilling the various roles (referred to as the Managed Hosts). It is possible to assign multiple roles to one Managed Host; for example, the ReST server and Web UI server roles can be run from one machine, and you would probably want to run Kibana from one of the Elasticsearch hosts. We would recommend that you do not combine any other roles to machines assigned to the ms_worker role or the elasticsearch role (other than adding Kibana to an Elasticsearch host).

To allow the Ansible Controller to communicate with the Managed Hosts, create an Ansible service account on all of the machines, and set up SSH keys to allow Ansible to communicate without passwords. The service account user will need root access on the managed VMs, and you probably want to set up the user to be able to gain root access without a password (otherwise, you will be typing in a password at an obnoxious frequency). ***For detailed step-by-step instructions for setting up the Ansible service account, refer to the DETAILED_PRECONFIG_STEPS.md file.***

When the machines are set up, edit the **hosts** file to assign the Managed Hosts to the appropriate category(ies). Refer to **site.yml** to see which roles apply to which host categories.

### Get the Project Source
You'll need the project source on the Ansible Controller. All the resources should be owned by the Ansible user to avoid permissions issues.
1. Log in to the Ansible Controller as the **ansible** user
2. Download this project (preferable via git clone) and save it somewhere (i.e., under /home/ansible)

### Internet Resources
Certain resources are not hosted in the standard repositories and so must be downloaded. This should be done on the Ansible Controller before trying to run the Ansible plays. The script **download_resources.sh** will download these dependencies to the **resources/** directory, and the Ansible tasks will copy them to the managed systems as necessary. You can change the file versions of the resources in the download script; however, since this will change the file names, you will also need to update the references to the files in the appropriate Ansible files. Comments in the script indicate exactly what will need to be changed for each item.

To run the downloader script:
1. Install the prerequisites (`yum install yum-utils`)
2. Ensure that the Ansible Controller is connected to the internet
3. Log in to the Ansible Controller as the **ansible** user
4. Go to the root folder of the project: `cd <path>/multiscanner-ansible` (i.e., `cd /home/ansible/multiscanner-ansible`)
5. Run the command: `sh download_resources.sh` 

### Install Ansible
You'll need to install Ansible on the Ansible Controller if it isn't already there:
1. Run the command: `sudo pip install ansible`
    - You may also need to `sudo yum install gcc python-devel libxml2-devel libxslt-devel openssl-devel` before this step

### Running the Plays
Running the plays is easy!
1. Log in to the Ansible Controller as the **ansible** user 
2. Go to the root folder of the project: `cd <path>/multiscanner-ansible` (i.e., `cd /home/ansible/multiscanner-ansible`)
3. Run the command: `ansible-playbook -i hosts site.yml --module-path custom_ansible_modules`</br>
(The process will take several minutes)<br/>
Note that the `--module-path custom_ansible_modules` flag is needed to tell Ansible to use the 
custom module defined for this project (one that compiles and installs an SELinux policy), which
is located in the `<project root>/custom_ansible_modules` directory. 


## Scaling
To increase performance/throughput, you might want to add additional hosts (workers, elasticsearch hosts, or Gluster hosts). To do this, simply set up the additional hosts with the appropriate user and SSH keys as described above, and then add their hostnames or IPs to the **hosts** file under the appropriate category.

