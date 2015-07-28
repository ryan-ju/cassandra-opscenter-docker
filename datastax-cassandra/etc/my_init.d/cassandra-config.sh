#!/bin/bash
set -e

set -- cassandra -f

CASSANDRA_CONFIG="/etc/cassandra"

# first arg is `-f` or `--some-option`
if [ "${1:0:1}" = '-' ]; then
	set -- cassandra "$@"
fi

if [ "$1" = 'cassandra' ]; then
	# TODO detect if this is a restart if necessary
	: ${CASSANDRA_LISTEN_ADDRESS='auto'}
	if [ "$CASSANDRA_LISTEN_ADDRESS" = 'auto' ]; then
		CASSANDRA_LISTEN_ADDRESS="$(hostname --ip-address)"
	fi

	CASSANDRA_BROADCAST_ADDRESS="$(/sbin/ip route|awk '/default/ {print $3}')"

	if [ "$CASSANDRA_BROADCAST_ADDRESS" = 'auto' ]; then
		CASSANDRA_BROADCAST_ADDRESS="$(hostname --ip-address)"
	fi
	: ${CASSANDRA_BROADCAST_RPC_ADDRESS:=$CASSANDRA_BROADCAST_ADDRESS}

	CASSANDRA_SEEDS="$CASSANDRA_BROADCAST_ADDRESS"

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
  sed -ri '/JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.port=$JMX_PORT"/i \
    JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote"' $CASSANDRA_CONFIG/cassandra-env.sh
  # Disable ssl
  sed -ri 's/JVM_OPTS="\$JVM_OPTS -Dcom.sun.management.jmxremote.ssl=true/JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl=false"/' $CASSANDRA_CONFIG/cassandra-env.sh
  # Disable auth
  sed -ri 's/JVM_OPTS="\$JVM_OPTS -Dcom.sun.management.jmxremote.authenticate=true"/JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.authenticate=false"/' $CASSANDRA_CONFIG/cassandra-env.sh
fi
