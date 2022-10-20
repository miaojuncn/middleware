#!/bin/bash

interface=$(ip --json --pretty route list default | jq --raw-output '.[0].dev')
ip_address=$(ip --json address | jq --raw-output '.[] | select( .ifname == "'${interface}'") | .addr_info | .[] | select( .family == "inet" ) | .local')

CONSUL_ADDR=192.168.10.47
PROC_NAME=node_exporter

ProcNumber=$(ps -ef |grep -w $PROC_NAME|grep -v grep|wc -l)
if [ $ProcNumber -le 0 ];then
    echo "node_exporter is not running"
    nohup node_exporter --no-collector.wifi --no-collector.hwmon --collector.filesystem.mount-points-exclude="^/(dev|proc|sys|run/k3s/containerd/.+|var/lib/docker/.+|var/lib/kubelet/pods/.+)($|/)" --collector.filesystem.ignored-fs-types="^(autofs|binfmt_misc|cgroup|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|mqueue|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|sysfs|tracefs)$" --collector.netclass.ignored-devices="^(veth.*|[a-f0-9]{15})$" --collector.netdev.device-exclude="^(veth.*|[a-f0-9]{15})$" > /tmp/node-exporter.log 2>&1 & 
else
    echo "node_exporter is running"
fi

curl -X PUT -d "{\"id\": \"${ip_address}\", \"name\": \"virtual-machine\", \"address\": \"${ip_address}\", \"port\": 9100, \"checks\": [{\"http\": \"http://${ip_address}:9100\", \"interval\": \"5s\"}]}" http://${CONSUL_ADDR}/v1/agent/service/register
