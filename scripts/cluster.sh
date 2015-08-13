#!/bin/bash
# This script is used to launch a cluster of Cassandra nodes and a Opscenter server node, connected together via a single network bridge.
# Required packages: pipework
DEFAULT_NUM_SEEDS=3
DEFAULT_BRIDGE_NAME="bridge0"
DEFAULT_BRIDGE_IP="172.18.100.1/24"
DEFAULT_CLUSTER_NAME="Test_Cluster"
DEFAULT_OPSCENTER_PORT="8888"

cat <<- EOF
  Use default settings [default y]? y/n
  * Default number of seeds = $DEFAULT_NUM_SEEDS
  * Default bridge name     = $DEFAULT_BRIDGE_NAME
  * Default bridge IP       = $DEFAULT_BRIDGE_IP
  * Default cluster name    = $DEFAULT_CLUSTER_NAME
  * Default Opscenter port  = $DEFAULT_OPSCENTER_PORT
EOF
read USE_DEFAULTS
: ${USE_DEFAULTS:=y}

if [[ $USE_DEFAULTS != 'y' ]]; then
  echo "Please enter number of Cassandra seed nodes [default to 3]:"
  read NUM_SEEDS
  : ${NUM_SEEDS:=$DEFAULT_NUM_SEEDS}

  echo "Please enter the name of the bridge [default to bridge0].  This will be created if not exist."
  read BRIDGE_NAME
  : ${BRIDGE_NAME:="DEFAULT_BRIDGE_NAME"}

  echo "Please enter the CIDR of the bridge [default to 172.17.100.1/24]:"
  read BRIDGE_IP
  : ${BRIDGE_IP:="$DEFAULT_BRIDGE_IP"}

  echo "Please enter the cluster name [default to Test_Cluster]:"
  read CLUSTER_NAME
  : ${CLUSTER_NAME:="$DEFAULT_CLUSTER_NAME"}

  echo "Please enter Opscenter port [default to 8888]:"
  read OPSCENTER_PORT
  : ${OPSCENTER_PORT:="$DEFAULT_OPSCENTER_PORT"}
else
  NUM_SEEDS=$DEFAULT_NUM_SEEDS
  BRIDGE_NAME=$DEFAULT_BRIDGE_NAME
  BRIDGE_IP=$DEFAULT_BRIDGE_IP
  CLUSTER_NAME=$DEFAULT_CLUSTER_NAME
  OPSCENTER_PORT=$DEFAULT_OPSCENTER_PORT
fi

# Add bridge device if not exist
#if [[ -z $(brctl show | grep $BRIDGE_NAME) ]]; then
#  echo "Bridge device not exist, create new one ..."
#  brctl addbr $BRIDGE_NAME
#fi

# If the device is down, make it up
#if [[ -n $(ip link show $BRIDGE_NAME | grep 'state DOWN') ]]; then
#  echo "Bridge device is down, make it up ..."
#  ip link set dev "$BRIDGE_NAME" up
#fi

# If device is still down, exit 1
#if [[ -n $(ip link show $BRIDGE_NAME | grep 'state DOWN') ]]; then
#  echo "Could not start bridge device $BRIDGE_NAME!"
#  echo "Script stopped!"
#  exit 1
#fi

# Build Cassandra broadcast IPs
if [[ $BRIDGE_IP =~ ([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+)\.([[:digit:]]+)/([[:digit:]]+) ]]; then
  PREFIX=${BASH_REMATCH[1]}
  SUFFIX=${BASH_REMATCH[2]}
  MASK=${BASH_REMATCH[3]}
  echo "PREFIX = $PREFIX, SUFFIX = $SUFFIX, MASK = $MASK"
fi
# If IP can't be parsed, exit 1
if [[ -z $PREFIX || -z $SUFFIX || -z $MASK ]]; then
  echo "Bridge IP $BRIDGE_IP cannot be correctly parsed!"
  echo "Script stopped!"
  exit 1
fi
for i in $(seq 1 $NUM_SEEDS); do
  BROADCAST_IPS+=($PREFIX.$(($SUFFIX+$i)))
done
echo "Broadcast addresses: $(IFS=, ; echo "${BROADCAST_IPS[*]}")"

# Start Cassandra containers
for i in "${BROADCAST_IPS[@]}"; do
  # Start a container
  docker run \
    -td \
    -e CASSANDRA_SEEDS=$(IFS=, ; echo "${BROADCAST_IPS[*]}") \
    -e CASSANDRA_BROADCAST_ADDRESS=$i \
    -e CLUSTER_NAME=$CLUSTER_NAME \
    -e OPSCENTER_ADDRESS="$PREFIX.1" \
    --net="none" \
    --name "cass$i" \
    stackoverflower/datastax-cassandra:2.2
  # Create network interface in the container
  pipework "$BRIDGE_NAME" -i eth0 "cass$i" "$i/$MASK"
done

# Start Opscenter container
docker run \
  -td \
  --name "opsc" \
  -p 8888:8888 \
  stackoverflower/datastax-opscenter:5.2
pipework "$BRIDGE_NAME" -i eth1 "opsc" "${PREFIX}.1/$MASK"
