#!/bin/bash
# Set up opscenter address.yaml

cd /usr/local/opscenter/datastax-agent*
mkdir -p ./conf/
: ${CASSANDRA_BROADCAST_ADDRESS='auto'}
# Broadcast address should be the public ip of the host.  The value should be passed as an environment variable when starting docker.
if [ "$CASSANDRA_BROADCAST_ADDRESS" = 'auto' ]; then
  CASSANDRA_BROADCAST_ADDRESS="$(/sbin/ip route|awk '/eth0/ {print $NF}')"
fi

# Opscenter address
: ${OPSCENTER_ADDRESS:="$CASSANDRA_BROADCAST_ADDRESS"}

echo "stomp_interface: $OPSCENTER_ADDRESS" >> ./conf/address.yaml
echo "local_interface: $CASSANDRA_BROADCAST_ADDRESS" >> ./conf/address.yaml
