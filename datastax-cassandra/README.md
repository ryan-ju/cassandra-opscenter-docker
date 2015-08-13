# Running the container
| Name | Meaning |
| :----: | :----: |
| CLUSTER_NAME | The name of the cluster.  Default `CLUSTER_NAME=Test_Cluster` |
| JMX_USER, JMX_PASSWORD | The JMX user credential that is stored in /etc/cassandra/jmxremote.password.  Anything using JMX connection (e.g., nodetool) needs to supply the credential.  Default `JMX_USER=cassandra`, `JMX_PASSWORD=cassandra` |
