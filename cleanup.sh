#!/bin/sh

set -e
export MSYS_NO_PATHCONV=1

NETWORK=agent-network
DB=database

docker rm -f "$DB"
docker network rm "$NETWORK"
