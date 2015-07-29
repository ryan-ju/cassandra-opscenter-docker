# Image contains:
# * Oracle JRE 1.8
# * Datastax Cassandra 2.2.0
# * Opscenter agent 5.2.0

FROM phusion/baseimage:latest

MAINTAINER Misaka

# Copy over files
COPY ./tmp/ /tmp/

# Install JRE
## Make directory for JRE
RUN mkdir -p /usr/lib/jvm
RUN tar zxvf /tmp/jre.tar.gz -C /usr/lib/jvm
## Update alternatives
RUN update-alternatives --install "/usr/bin/java" "java" "$(echo /usr/lib/jvm/jre*/bin/java)" 1
RUN update-alternatives --set java /usr/lib/jvm/jre*/bin/java

# Install Cassandra
# http://docs.datastax.com/en/cassandra/2.1/cassandra/install/installDeb_t.html
RUN echo "deb http://debian.datastax.com/community stable main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list
RUN curl -L http://debian.datastax.com/debian/repo_key | apt-key add -

## Replace default ubuntu archive with mirror site to speed up download
RUN sed -i 's/archive/cn.archive/g' /etc/apt/sources.list

## TODO the following should be one line
RUN apt-get update
RUN apt-get -y install dsc22
RUN apt-get -y install cassandra-tools

## Create volume
VOLUME /var/lib/cassandra

## Need to stop the auto started service
RUN service cassandra stop
RUN rm -rf /var/lib/cassandra/data/system/*

# Install Opscenter agent
## Install sysstat
RUN apt-get -y install sysstat

## Copy over tar file
RUN mkdir -p /usr/local/opscenter
RUN tar -xzvf /tmp/datastax-agent.tar.gz -C /usr/local/opscenter/

# Remove unnecessary files
RUN rm /tmp/jre.tar.gz /tmp/datastax-agent.tar.gz

# Add services
COPY etc/ etc/
# Make the service files executable
RUN chmod u+x /etc/service/**/run /etc/service/**/check /etc/service/**/control/* /etc/my_init.d/*.sh

# Clean up
RUN rm -rf /var/lib/apt/lists/*

# Expose ports
## 7000: intra-node communication
## 7001: TLS intra-node communication
## 7199: JMX
## 9042: CQL
## 9160: thrift service
## 61621: Opscenter agent port
EXPOSE 7000 7001 7199 9042 9160 61621
