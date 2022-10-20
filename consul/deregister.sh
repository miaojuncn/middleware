#!/bin/bash

CONSUL_ADDR=192.168.10.47

interface=$(ip --json --pretty route list default | jq --raw-output '.[0].dev')
ip_address=$(ip --json address | jq --raw-output '.[] | select( .ifname == "'${interface}'") | .addr_info | .[] | select( .family == "inet" ) | .local')


for i `seq 1 3`
do
    curl -s -X PUT http://${CONSUL_ADDR}/v1/agent/service/deregister/${ip_address}
done
