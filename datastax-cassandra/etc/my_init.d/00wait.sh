#!/bin/bash
# Wait for pipework to finish and sleep a bit to allow IP to be correctly configured on eth0
# Because Phusion executes my_init.d/ scripts sequentially, this script makes sure the NIC is correctly set up before other scripts are run
pipework --wait -i eth0 && sleep 5
