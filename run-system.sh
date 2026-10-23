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
# The seeder runs in the foreground, so the script waits for it. If it fails, set -e stops everything.
docker run -d --name "$GATEWAY" --network "$NETWORK" --label "$LABEL" -v /var/run/docker.sock:/var/run/docker.sock -v "$(pwd)/mcp_config.yaml:/mcp_config.yaml:ro" -v "$(pwd)/mcp_secret.env:/run/secrets/database-url:ro" docker/mcp-gateway:latest --transport=sse --secrets=/run/secrets/database-url --allow-unauthenticated --servers=cockroachdb --tools=execute_query --config=/mcp_config.yaml
until docker logs "$GATEWAY" 2>&1 | grep -q "Start sse server"; do sleep 1; done
docker build --target agent --label "$LABEL" -t "$AGENT_IMAGE" .
docker run --rm --network "$NETWORK" --label "$LABEL" -v "$(pwd)/secret.ollama-api-key:/run/secrets/openai-api-key:ro" -e MCP_SERVER_URL="http://$GATEWAY:8811/sse" -e DATABASE_DIALECT=PostgreSQL -e QUESTION="What are the top 3 albums by sales?" -e OPENAI_API_BASE_URL=https://ollama.com/v1 -e OPENAI_MODEL_NAME=gpt-oss:20b "$AGENT_IMAGE" 

