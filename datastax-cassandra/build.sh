#!/bin/bash
echo "Please enter tag for the image [default to cassandra-opscenter:2.2]:"
read TAG
: ${TAG:="cassandra-opscenter:2.2"}

OPSCENTER_VERSION=5.2.0

mkdir -p ./tmp

# Exit if JRE tar does not exist
if [[ ! -e ./tmp/jre.tar.gz ]]; then
  exit 1
fi

# Download Opscenter agent if not exist
if [[ ! -e  ./tmp/datastax-agent.tar.gz ]]; then
  curl -L -o ./tmp/datastax-agent.tar.gz "http://downloads.datastax.com/community/datastax-agent-${OPSCENTER_VERSION}.tar.gz"
fi

docker build -t "$TAG" .
