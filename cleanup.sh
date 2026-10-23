#!/bin/sh

set -e
export MSYS_NO_PATHCONV=1

NETWORK=agent-network
DB=database
GATEWAY=mcp-gateway
VOLUME=chinook-data
SEEDER_IMAGE=chinook-seeder:1.0
AGENT_IMAGE=chinook-agent:1.0

docker rm -f "$GATEWAY"
docker ps -aq --filter label=docker-mcp=true | xargs -r docker rm -f
docker rm -f "$DB"
docker volume ls -q --filter label=project=chinook-agent | xargs -r docker volume rm
docker network ls -q --filter label=project=chinook-agent | xargs -r docker network rm
docker images -q --filter label=project=chinook-agent | xargs -r docker rmi