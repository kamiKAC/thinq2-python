#!/bin/sh
export MQTT_HOST="${MQTT_HOST:-`/sbin/ip route|awk '/default/{print $3}'`}"
exec python3 thinq2_mqtt.py
