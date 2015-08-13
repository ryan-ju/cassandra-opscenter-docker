#!/bin/bash
echo "Please enter Cassandra container name prefix [default to cass]:"
read CASS_NAME_PREFIX
: ${CASS_NAME_PREFIX:=cass}

echo "Please enter Opscenter container name prefix [default to opsc]:"
read OPSC_NAME_PREFIX
: ${OPSC_NAME_PREFIX:=opsc}

CONTAINERS=($(docker ps -a | awk "NR != 1 && \$NF ~ /$CASS_NAME_PREFIX.*/ {print \$1}"))
CONTAINERS+=($(docker ps -a | awk "NR != 1 && \$NF ~ /$OPSC_NAME_PREFIX.*/ {print \$1}"))
echo "Containers to be deleted: ${CONTAINERS[@]}"
docker rm -f ${CONTAINERS[@]}
