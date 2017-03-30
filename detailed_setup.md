# Preconfiguration Instructions
This document describes the recommended steps for performing the initial configuration of the machine that will be used to run the Ansible plays against the target hosts, as well as the target hosts themselves. For the purposes of this document, the machine that runs the Ansible scripts will be referred to as the "**Ansible Controller**" and the machines that will be configured by Ansible will be referred to as the "**Managed Systems**".

## General First Steps
1. The most generic first step is to physically set up the systems. For the Managed Systems, this might be creating virtual machines
2. Set the machines' hostnames
3. Perform any IP address or other network configurations necessary (will depend on your operating environment)

*NOTE:* if you are using virtual machines, we recommend automating the VM creation process as much as possible. As a simplisting example, you could create a template with a script that will set the hostname and perform other mandatory configurations. Then just clone this template for each Managed System and run the script.

## Create Ansible User
TODO

## Copy SSH Keys
TODO
