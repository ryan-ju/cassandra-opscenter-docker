#!/bin/bash
echo "Please enter Docker image name [default to stackoverflower/datastax-opscenter:5.2]":
read TAG
: ${TAG:="stackoverflower/datastax-opscenter:5.2"}
echo "Please enter container name [default to opsc]:"
read NAME
: ${NAME:=opsc}

docker run -td \
  -p 8888:8888 -p 61620:61620 \
  --name "$NAME" "$TAG"
