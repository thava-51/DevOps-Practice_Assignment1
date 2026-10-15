#!/bin/sh

set -e
export MSYS_NO_PATHCONV=1

NETWORK=agent-network
DB=database
GATEWAY=mcp-gateway
VOLUME=chinook-data
LABEL=project=chinook-agent

docker network create --label "$LABEL" "$NETWORK"  
