#!/bin/bash
echo "Please enter tag for the image [default to stackoverflower/datastax-opscenter:5.2]:"
read TAG
: ${TAG:="stackoverflower/datastax-opscenter:5.2"}

docker build -t "$TAG" .
