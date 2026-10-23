#!/bin/sh

set -e
export MSYS_NO_PATHCONV=1

NETWORK=agent-network
DB=database
GATEWAY=mcp-gateway
VOLUME=chinook-data
LABEL=project=chinook-agent
SEEDER_IMAGE=chinook-seeder:1.0
AGENT_IMAGE=chinook-agent:1.0

DB_USER=chinook
DB_NAME=chinook
DB_PASSWORD=devops123

docker network create --label "$LABEL" "$NETWORK"
docker volume create --label "$LABEL" "$VOLUME"
docker run -d --name "$DB" --network "$NETWORK" --label "$LABEL" -e POSTGRES_USER="$DB_USER" -e POSTGRES_PASSWORD="$DB_PASSWORD" -e POSTGRES_DB="$DB_NAME" -v "$VOLUME":/var/lib/postgresql/data postgres:17
docker build --target seeder -t "$SEEDER_IMAGE" --label "$LABEL" .
until docker exec "$DB" pg_isready -U "$DB_USER" -d "$DB_NAME"; do sleep 1; done
docker run --rm --network "$NETWORK" --label "$LABEL" -v "$(pwd)/Chinook.db:/app/Chinook.db:ro" -e SQLITE_FILE=/app/Chinook.db -e DATABASE_URL="postgres://$DB_USER:$DB_PASSWORD@$DB:5432/$DB_NAME" "$SEEDER_IMAGE"
docker run -d --name "$GATEWAY" --network "$NETWORK" --label "$LABEL" -v /var/run/docker.sock:/var/run/docker.sock -v "$(pwd)/mcp_config.yaml:/mcp_config.yaml:ro" -v "$(pwd)/mcp_secret.env:/run/secrets/database-url:ro" docker/mcp-gateway:latest --transport=sse --secrets=/run/secrets/database-url --allow-unauthenticated --servers=cockroachdb --tools=execute_query --config=/mcp_config.yaml
docker build --target agent -t
docker build --target agent --label "$LABEL" -t "$AGENT_IMAGE" .

