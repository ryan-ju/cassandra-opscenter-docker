#!/bin/bash
# Set up opscenter address.yaml
cd /usr/local/opscenter/datastax-agent*
mkdir -p ./conf/
echo "stomp_interface: $(/sbin/ip route|awk '/default/ { print $3 }')" >> ./conf/address.yaml
