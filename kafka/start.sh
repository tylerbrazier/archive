#!/bin/bash
set -e -u

finish() {
  echo "$1"
  echo "Press [Enter]"
  read
}

trap 'finish "Error during start"' ERR

echo "Loading configuration.txt..."
cd "$(dirname "$0")"
source ./configuration.txt
echo

echo "Starting Boot2docker..."
cd "$b2d_dir"
./boot2docker.exe start >/dev/null
echo

zk="${zk_image}:${zk_tag}"
zk_mnt_map="${zk_b2d_data}:${zk_container_data}"
zk_port_map="${zk_port}:${zk_port}"
kafka="${kafka_image}:${kafka_tag}"
kafka_mnt_map="${kafka_b2d_data}:${kafka_container_data}"
kafka_port_map="${kafka_port}:${kafka_port}"

cmd='
set -e -u
docker ps | grep -F '\'"$zk"\'' >/dev/null \
  && echo "'"$zk"' is already running." \
  || { echo "Starting '"$zk"'"; \
       docker run -d \
         -p '"$zk_port_map"' \
         -v '"$zk_mnt_map $zk"' \
         >/dev/null; \
     }

docker ps | grep -F '\'"$kafka"\'' >/dev/null \
  && echo "'"$kafka"' is already running." \
  || { echo "Starting '"$kafka"'"; \
       docker run -d \
         -p '"$kafka_port_map"' \
         -v '"$kafka_mnt_map $kafka"' \
         >/dev/null; \
     }
'

./boot2docker.exe ssh "$cmd"

finish "Started successfully"
echo
