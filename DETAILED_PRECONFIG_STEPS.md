# Preconfiguration Instructions
This document describes the recommended steps for performing the initial configuration of the machine that will be used to run the Ansible plays against the target hosts, as well as the target hosts themselves. For the purposes of this document, the machine that runs the Ansible scripts will be referred to as the "**Ansible Controller**" and the machines that will be configured by Ansible will be referred to as the "**Managed Hosts**".

## General First Steps
1. The most generic first step is to physically set up the systems. For the Managed Hosts, this might be creating virtual machines
2. Set the machines' hostnames
3. Perform any IP address or other network configurations necessary (will depend on your operating environment)

*NOTE:* if you are using virtual machines, we recommend automating the VM creation process as much as possible. As a simplistic example, you could create a template with a script that will set the hostname and perform other mandatory configurations. Then just clone this template for each Managed System and run the script.

## Create Ansible User
You should have a dedicated Ansible user on the Ansible Controller and the Managed Hosts. The username and password should be the same on all machines. The best way to achieve this is to put all the machines on the same Active Directory domain and create the user at the domain level. If this is not an option, then manually add the user by following these steps:<br/>
***On ALL MACHINES (Ansible Controller and all Managed Hosts):***
1. Log in to the machine using an account that can gain root access
2. Acquire root access: ```sudo su -```
3. Enter the following commands:
    * ```useradd ansible```
    * ```(printf "THE_NEW_PASSWORD\nTHE_NEW_PASSWORD\n\n" && cat) | passwd ansible```<br/>
    NOTE: if you use special characters in the password, be sure to escape them with a ```\``` (i.e., to include the ```$``` character, write it as ```\$```)
    * Press [Enter] 

## Give Ansible User Root Access
Once the Ansible user has been added to all machines, it needs to be able to acquire root privileges without a password on the Managed Hosts.<br/>
***On each Managed Host:***
1. Log in to the machine using an account that can gain root access
2. Acquire root access: ```sudo su -```
3. Open the sudoers file: ```visudo```
4. Enter Edit mode: ```i```
5. Add the following line at the end of the file: ```ansible ALL=(ALL) NOPASSWD: ALL```
6. Save and close the file: ```[Esc]:wq```

## Copy SSH Keys
The Ansible Controller needs to be able to log in to the Managed Hosts without a password, so it is necessary to create SSH keys and copy them to all the Managed Hosts.<br/>
***On the Ansible Controller:***
1. Generate SSH keys: ```ssh-keygen -t rsa```
2. For each Managed Host, run the ssh-copy-id command: ```ssh-copy-id ansible@MANAGED_HOST```<br/>
where MANAGED_HOST is the IP or hostname of the Managed Host

ALTERNATIVELY, you can create a script to perform Step 2 above:
1. Create a new file: ```vi copy_keys.sh```
2. Enter insert mode: ```i```
3. Type or paste the following code into the file: (NOTE: Replace the contents of the ```tgt_hosts``` array with the actual hostnames or IPs of all the Managed Hosts)
```
#!/bin/bash

user_=ansible
tgt_hosts=(managed-host1.mscan.dev managed-host2.mscan.dev managed-host3.mscan.dev)

for h_ in ${tgt_hosts[@]}; do    
    ssh-copy-id ansible@${h_}  
done
``` 
4. Save and close the file: ```[Esc]:wq```
5. Run the script: ```sh copy_keys.sh```
