#!/bin/bash

set -e

set -- cassandra -f

CASSANDRA_CONFIG="/etc/cassandra"

JRE_HOME="$(echo /usr/lib/jvm/jre*)"

JRE_MANAGEMENT="$JRE_HOME/lib/management"

# first arg is `-f` or `--some-option`
if [ "${1:0:1}" = '-' ]; then
	set -- cassandra "$@"
fi

if [ "$1" = 'cassandra' ]; then
	# Change cluster name
	: ${CLUSTER_NAME:=Test_Cluster}
	sed -ri "s/(cluster_name:).*/\1 '$CLUSTER_NAME'/" "$CASSANDRA_CONFIG/cassandra.yaml"

	# TODO detect if this is a restart if necessary
	: ${CASSANDRA_LISTEN_ADDRESS='auto'}
	if [ "$CASSANDRA_LISTEN_ADDRESS" = 'auto' ]; then
#		LISTEN_ADDRESS=$(ip addr show eth0 | grep "inet " | awk '{print $2}')
#		if [[ $LISTEN_ADDRESS =~ ([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+)/([[:digit:]]+) ]]; then
			CASSANDRA_LISTEN_ADDRESS="$(/sbin/ip route|awk '/eth0/ {print $NF}')"
#		fi
	fi

	: ${CASSANDRA_BROADCAST_ADDRESS='auto'}
  # Broadcast address should be the public ip of the host.  The value should be passed as an environment variable when starting docker.
	if [ "$CASSANDRA_BROADCAST_ADDRESS" = 'auto' ]; then
		CASSANDRA_BROADCAST_ADDRESS="$(/sbin/ip route|awk '/eth0/ {print $NF}')"
	fi

	: ${CASSANDRA_BROADCAST_RPC_ADDRESS:=$CASSANDRA_BROADCAST_ADDRESS}

	: ${CASSANDRA_SEEDS:="$CASSANDRA_BROADCAST_ADDRESS"}

	sed -ri 's/(- seeds:) "127.0.0.1"/\1 "'"$CASSANDRA_SEEDS"'"/' "$CASSANDRA_CONFIG/cassandra.yaml"

  # RPC address affects both RPC and native connection
  sed -ri 's/^(# )?(rpc_address:).*/\2 0.0.0.0/' "$CASSANDRA_CONFIG/cassandra.yaml"

	for yaml in \
		broadcast_address \
		broadcast_rpc_address \
		cluster_name \
		endpoint_snitch \
		listen_address \
		num_tokens \
	; do
		var="CASSANDRA_${yaml^^}"
		val="${!var}"
		if [ "$val" ]; then
			sed -ri 's/^(# )?('"$yaml"':).*/\2 '"$val"'/' "$CASSANDRA_CONFIG/cassandra.yaml"
		fi
	done

	for rackdc in dc rack; do
		var="CASSANDRA_${rackdc^^}"
		val="${!var}"
		if [ "$val" ]; then
			sed -ri 's/^('"$rackdc"'=).*/\1 '"$val"'/' "$CASSANDRA_CONFIG/cassandra-rackdc.properties"
		fi
	done

  # Enable remote JMX
  sed -ri 's/^(# )?JVM_OPTS="\$JVM_OPTS -Djava.rmi.server.hostname=<public name>"/JVM_OPTS="$JVM_OPTS -Djava.rmi.server.hostname=127.0.0.1"/' $CASSANDRA_CONFIG/cassandra-env.sh
  sed -ri 's/^(# )?LOCAL_JMX=yes/# LOCAL_JMX=yes/' $CASSANDRA_CONFIG/cassandra-env.sh
  sed -ri '/JVM_OPTS="\$JVM_OPTS -Dcom.sun.management.jmxremote.port=\$JMX_PORT"/i \
    JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote"' $CASSANDRA_CONFIG/cassandra-env.sh
  # Disable ssl
  sed -ri 's/JVM_OPTS="\$JVM_OPTS -Dcom.sun.management.jmxremote.ssl=true/JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl=false"/' $CASSANDRA_CONFIG/cassandra-env.sh

	# Uncomment the following to disable JMX auth
  # sed -ri 's/JVM_OPTS="\$JVM_OPTS -Dcom.sun.management.jmxremote.authenticate=true"/JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.authenticate=false"/' $CASSANDRA_CONFIG/cassandra-env.sh

	# Password protect remote JMX
	: ${JMX_USER:=cassandra}
	: ${JMX_PASSWORD:=cassandra}
	cp $JRE_MANAGEMENT/jmxremote.password.template /etc/cassandra/jmxremote.password
	echo "$JMX_USER $JMX_PASSWORD" >> /etc/cassandra/jmxremote.password
	# Read only by the owner
	chmod 600 /etc/cassandra/jmxremote.password
	# Add read write access to jmxremote.access
	echo "$JMX_USER readwrite" >> $JRE_MANAGEMENT/jmxremote.access
fi
