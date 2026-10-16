#!/bin/sh

set -e
export MSYS_NO_PATHCONV=1

NETWORK=agent-network
DB=database
GATEWAY=mcp-gateway
VOLUME=chinook-data
LABEL=project=chinook-agent

DB_USER=chinook
DB_NAME=chinook
DB_PASSWORD=devops123

docker network create --label "$LABEL" "$NETWORK"
docker volume create --label "$LABEL" "$VOLUME"
docker run -d --name "$DB" --network "$NETWORK" --label "$LABEL" -e POSTGRES_USER="$DB_USER" -e POSTGRES_PASSWORD="$DB_PASSWORD" -e POSTGRES_DB="$DB_NAME" -v "$VOLUME":/var/lib/postgresql/data postgres:17
