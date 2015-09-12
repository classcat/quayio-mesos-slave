FROM ubuntu:trusty
MAINTAINER ClassCat Co.,Ltd. <support@classcat.com>

########################################################################
# ClassCat/Mesos-Slave Dockerfile
#   Maintained by ClassCat Co.,Ltd ( http://www.classcat.com/ )
########################################################################

#--- HISTORY -----------------------------------------------------------
#
#--- TODO --------------------------------------------------------------
#
#--- DESCRIPTION -------------------------------------------------------
#
#-----------------------------------------------------------------------

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y upgrade \
  && apt-get install -y language-pack-en language-pack-en-base \
  && apt-get install -y language-pack-ja language-pack-ja-base \
  && update-locale LANG="en_US.UTF-8" \
  && apt-get install -y openssh-server supervisor \
  && mkdir -p /var/run/sshd \
  && sed -i.bak -e "s/^PermitRootLogin\s*.*$/PermitRootLogin yes/" /etc/ssh/sshd_config

COPY assets/supervisord.conf /etc/supervisor/supervisord.conf

# OpenJDK 7
RUN apt-get install -y openjdk-7-jdk

# Mesos
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF \
  && echo "deb http://repos.mesosphere.com/ubuntu trusty main" > /etc/apt/sources.list.d/mesosphere.list \
  && apt-get update \
  && apt-get install -y mesos

# Apache Spark
WORKDIR /usr/local
RUN wget http://ftp.riken.jp/net/apache/spark/spark-1.4.1/spark-1.4.1-bin-hadoop2.4.tgz \
  && tar xfz spark-1.4.1-bin-hadoop2.4.tgz \
  && ln -s spark-1.4.1-bin-hadoop2.4 spark

COPY assets/cc-init.sh /opt/cc-init.sh

#EXPOSE 22 80

CMD /opt/cc-init.sh; /usr/sbin/sshd -D

#CMD /opt/cc-init.sh; /usr/bin/supervisord -c /etc/supervisor/supervisord.conf


### End of Dockerfile ###
