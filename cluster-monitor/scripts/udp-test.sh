#!/bin/bash

# Send test data to statsd

message="test.count:1|c"
host="127.0.0.1"
port=8125
delay="1s"

echo "Sending $message to $host on port $port every $delay"
while true; do
  echo $message | nc -u -q0 $host $port
  sleep $delay
done
