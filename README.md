# multiscanner-ansible
Ansible configurations for distributed MultiScanner installations (WORK IN PROGRESS)

## Purpose
This project exists to facilitate configuring the [MultiScanner](https://github.com/MITRECND/multiscanner) file analysis framework in a distributed setting. It defines [Ansible](https://www.ansible.com/get-started) configurations to enable automated configuration management of machines in a MultiScanner setup. 

## MultiScanner Distributed Setup
TODO - describe nodes: workers, messaging servers (Rabbit), web server, Elasticsearch, Distributed File System, etc. Provide breakdown of what each node does and what services/applications are installed

## Setup
TODO - describe process of setting up VMs, generating SSH keys, and other basic Ansible things

## Scaling
TODO - describe reasons for adding new machines (ES nodes, worker nodes)
TODO - describe process for adding new nodes (create VM, update config files to include new IP/hostname, etc)

