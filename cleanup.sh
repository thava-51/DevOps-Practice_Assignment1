#!/bin/sh

set -e
export MSYS_NO_PATHCONV=1

NETWORK=agent-network
DB=database
GATEWAY=mcp-gateway
VOLUME=chinook-data
SEEDER_IMAGE=chinook-seeder:1.0

docker rm -f "$GATEWAY"
docker rm -f "$DB"
docker volume rm "$VOLUME"
docker network rm "$NETWORK"
docker rmi "$SEEDER_IMAGE"