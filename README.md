# What is this project?
This project provides Datastax Cassandra and Opscenter in containers.

# Why I started this project?
* The common ubuntu base image is not adequate.  [Phusion base image](http://phusion.github.io/baseimage-docker/) is used instead.
* Oracle JRE is used instead of OpenJDK JRE.
* Package Cassandra and Opscenter agent in the same container for easy deployment.
* Data persistence (if a container dies, the data will not be lost and can be taken up by a new container).
* Possible Kubernetes integration to create cluster of Cassandra.

# Build the project
## Prerequisite
Must download and place the following files under `datastax-cassandra/tmp/` (create it if not exist).
* jre.tar.gz ([download link](http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html)).
* datastax-agent.tar.gz ([download link](http://downloads.datastax.com/community/datastax-agent-5.2.0.tar.gz)).
