#!/bin/bash
echo "Please enter Docker image name [default to stackoverflower/datastax-cassandra:2.2]":
read TAG
: ${TAG:="stackoverflower/datastax-cassandra:2.2"}
echo "Please enter container name [default to cass1]:"
read NAME
: ${NAME:=cass1}

docker run -ti \
  -p 7000:7000 -p 7001:7001 -p 7199:7199 -p 9042:9042 -p 9160:9160 -p 61621:61621 \
  --name "$NAME" "$TAG"
