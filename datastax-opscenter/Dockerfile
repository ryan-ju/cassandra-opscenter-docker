# Image contains:
# * Opscenter 5.2.0

FROM phusion/baseimage:latest

MAINTAINER Misaka

# Install opscenter.  http://docs.datastax.com/en/opscenter/5.1/opsc/install/opscInstallDeb_t.html
RUN echo "deb http://debian.datastax.com/community stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.community.list

RUN curl -L http://debian.datastax.com/debian/repo_key | sudo apt-key add -

# Change apt sources so update runs faster
RUN sed -i 's/archive/cn.archive/g' /etc/apt/sources.list

RUN apt-get update

RUN apt-get -y install opscenter

# Remove opscenterd start up scripts
RUN rm -f /etc/rc[0-6].d/*opscenterd

# Add services
COPY etc/ etc/
# Make the service files executable
RUN chmod u+x /etc/service/**/run

# Clean up
RUN rm -rf /var/lib/apt/lists/*

# Expose ports
## 8888: web interface port
## 61620: listen port for agent connections
EXPOSE 8888 61620
