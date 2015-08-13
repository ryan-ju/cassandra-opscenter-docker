#!/bin/bash
# Add hostname to /etc/hosts so Cassandra is happy
echo "$(/sbin/ip route|awk '/eth0/ {print $NF}')  $(hostname)" >> /etc/hosts
