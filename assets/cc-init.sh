#!/bin/bash

########################################################################
# ClassCat/Mesos-Slave Asset files
# Copyright (C) 2015 ClassCat Co.,Ltd. All rights reserved.
########################################################################

#--- HISTORY -----------------------------------------------------------
#-----------------------------------------------------------------------


######################
### INITIALIZATION ###
######################

function init () {
  echo "ClassCat Info >> initialization code for ClassCat/Mesos-Slave"
  echo "Copyright (C) 2015 ClassCat Co.,Ltd. All rights reserved."
  echo ""
}


############
### SSHD ###
############

function change_root_password() {
  if [ -z "${ROOT_PASSWORD}" ]; then
    echo "ClassCat Warning >> No ROOT_PASSWORD specified."
  else
    echo -e "root:${ROOT_PASSWORD}" | chpasswd
    # echo -e "${password}\n${password}" | passwd root
  fi
}


function put_public_key() {
  if [ -z "$SSH_PUBLIC_KEY" ]; then
    echo "ClassCat Warning >> No SSH_PUBLIC_KEY specified."
  else
    mkdir -p /root/.ssh
    chmod 0700 /root/.ssh
    echo "${SSH_PUBLIC_KEY}" > /root/.ssh/authorized_keys
  fi
}


###################
### Mesos-Slave ###
###################

function proc_mesos_slave () {
  echo "zk://${MESOS_MASTER_IP}:2181/mesos" > /etc/mesos/zk

  service mesos-slave restart
}


#############
### SPARK ###
#############

function proc_spark () {
  cp -p /usr/local/spark/conf/log4j.properties.template /usr/local/spark/conf/log4j.properties

  # log4j.rootCategory=INFO, console
  sed -i.bak -e "s/log4j\.rootCategory\s*=.*/log4j.rootCategory=WARN, console/" /usr/local/spark/conf/log4j.properties

  echo 'export PATH=/usr/local/spark/bin:$PATH' > /root/.bash_profile
}


##################
### SUPERVISOR ###
##################
# See http://docs.docker.com/articles/using_supervisord/

function proc_supervisor () {
  cat > /etc/supervisor/conf.d/supervisord.conf <<EOF
[program:ssh]
command=/usr/sbin/sshd -D

#[program:rsyslog]
#command=/usr/sbin/rsyslogd -n

#[program:pyspark]
#command=/usr/local/spark/bin/pyspark
#environment=IPYTHON=1,IPYTHON_OPTS="notebook --profile=ccnb"
##environment=IPYTHON=1,IPYTHON_OPTS="notebook --profile=ccnb",PATH="/usr/local/spark/bin:%(ENV_PATH)s"
EOF
}



### ENTRY POINT ###

init 
change_root_password
put_public_key
proc_mesos_slave
#proc_spark
#proc_supervisor

exit 0


### End of Script ###

