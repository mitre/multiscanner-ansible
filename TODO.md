# TODO

## PRIORITY 1:
* Fix MS-specific roles so that updates to the config files result in service restarts. Currently, config file updates happen 
in the *ms_common* role, but services are defined in the *ms_webserver*, *ms_restserver*, and *ms_worker* roles.<br/>
  * Workaround 1: reference tasks and templates from the *ms_common* role in the specific service roles
  * Wokraround 2: use 'hostvars' Ansible concept to implement the current (failed) approach, which is to set a variable in the *ms_common*
  role and then reference that in the other roles. 
  
  Either approach above leads to annoying coupling among the roles...
