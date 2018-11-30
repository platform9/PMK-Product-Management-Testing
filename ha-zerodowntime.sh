#!/bin/bash

# Author: Jeremy Kuhnash, jkuhnash@mesosphere.com
# Contributor: Eric Bannon, ebannon@mesosphere.com 
# Licensed under the Apache 2.0 software license, no warranty implied.
# https://www.apache.org/licenses/LICENSE-2.0

DEBUG=1
#HOST="10.0.0.155"
HOST=$1
CONSTRAINT_KEY="hostname"
CONSTRAINT_VALUE="UNIQUE"

_debug() {
    if [ $DEBUG -gt 0 ]
    then
        echo ${1}
    fi
}

_jq() {
    echo ${row} | base64 --decode | jq -r ${1}
}

#APPS='[{"name":"foo"},{"name":"bar"}]'
APPS=$(dcos marathon app list --json)
for row in $(echo "${APPS}" | jq -r '.[] | @base64'); do
    ID=$(_jq '.id')
    _debug "ID==$ID"
#   dcos marathon app show /test/two-instances | jq '. | .tasks[] | select(.host=="10.0.0.155") | .appId'
    HOSTS=$(dcos marathon app show $ID | jq '. | .tasks[] | .host')
    _debug "HOSTS=$HOSTS"
    [[ $HOSTS =~ $HOST ]];
        echo "$ID: Deployed host matches $HOST"
        TASK=$(dcos marathon app show $ID)
        INSTANCES=$(_jq '.instances')
        _debug "INSTANCES==$INSTANCES"
        CONSTRAINTS=$(_jq '.constraints')
        _debug "CONSTRAINTS==$CONSTRAINTS"

        # Note: Even if a service is instance count 0, lets report it in case its a race condition with the script
        # and a testing exercise via scaling (start, suspend, start, etc)
        if [ $INSTANCES -lt 2 ]
        then
            echo "$ID requires review. Cause: Instance count is $INSTANCES, expected > 1."
        fi

        # Note: Ignore case check for contraint via grep instead of ~=
        if ! [[ $CONSTRAINTS =~ $CONSTRAINT_KEY ]];
        then
            echo "$ID requires review. Cause: Constraint $CONSTRAINT_KEY not found."
        fi

        if ! [[ $CONSTRAINTS =~ $CONSTRAINT_VALUE ]];
        then
            echo "$ID requires review. Cause: Constraint $CONSTRAINT_VALUE not found."
        fi

        echo "-------------------------------------------------------------------------"
done
