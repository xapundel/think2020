#!/bin/sh

SERVICE_NAME=$1
CA_CERT_FILE=/root/ca.crt

# Service for MQTT message publication using Mosquitto client
echo "[hellothink] Service was started"

TOPIC_NAME=thinkmoscow2020/${HZN_DEVICE_ID}/${SERVICE_NAME}/hello
MQTT_URL=${MQTT_BROKER_URI}/${TOPIC_NAME}

echo "Hello Edge" > msg
mosquitto_pub -L ${MQTT_URL} -q 1 -r -f msg --cafile ${CA_CERT_FILE}
if [ $? -eq 0 ]; then
  echo "[hellothink] hello msg published to MQTT"
else
  echo "[hellothink] MQTT publication error"
  exit 1
fi

sleep 86400 # do not finish process immediately