#!/bin/bash

# Service for MQTT message publication using Mosquitto client
echo "[hellothink] Service was started"

TOPIC_NAME=thinkmoscow2020/${HZN_DEVICE_ID}/hello

echo "${USER_EMAIL}" > msg
mosquitto_pub --insecure -L ${MQTT_BROKER_URI}/${TOPIC_NAME} -q 1 -r -f msg
if [ $? -eq 0 ]; then
  echo "[hellothink] hello msg published to MQTT"
else
  echo "[hellothink] MQTT publication error"
fi

sleep 86400 # do not finish process immediately