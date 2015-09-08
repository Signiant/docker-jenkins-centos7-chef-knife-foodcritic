# docker-jenkins-centos7-chef-knife-foodcritic
Container for a Jenkins build node that uses food critic and testkitchen to check chef recipes.  Also allows for promotion to a chef server.

## Variables:

- BUILD_USER : the OS user to run the Jenkins slave as/perform all actions (default: bldmgr)
- RUN_SLAVE: If set, will start the Jenkins JNLP slave software; otherwise, runs sshd
- MASTER_ADDR : the name or IP/port of the Jenkins master server
- SLAVE_ID: The name of the slave already pre-created in the Jenkins master
- SECRET: The secret for the Jenkins slave (obtained in the Jenkins master UI for this slave)

## Example Docker run

```
#!/bin/bash

docker run -d -e "SLAVE_ID=java-slave-1" \
              -e "MASTER_ADDR=jenkinsmaster1.acme.com:8080" \
              -e "RUN_SLAVE=1" \
              -e "SECRET=12345" \
              -v /mount/credentials:/credentials \
              -v /Releases:/var/lib/jenkins/Releases \
              mycontainer
```
