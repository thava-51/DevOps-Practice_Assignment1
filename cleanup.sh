#!/bin/sh

set -e
export MSYS_NO_PATHCONV=1

NETWORK=agent-network
DB=database
VOLUME=chinook-data

docker rm -f "$DB"
docker volume rm "$VOLUME"
docker network rm "$NETWORK"
