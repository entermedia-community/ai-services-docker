#!/bin/bash

pkill -f ./qdrant

HOST="$1"
PORT="$2"

if [ -z "$HOST" ] || [ -z "$PORT" ]; then
	echo "Usage: $0 <host> <port>"
	exit 1
fi

cd /qdrant
./qdrant --bootstrap http://mediadb45.entermediadb.net:6335 --uri "http://$HOST:$PORT" > /dev/null 2>&1 &
