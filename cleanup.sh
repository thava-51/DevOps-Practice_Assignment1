#!/bin/sh

set -e
export MSYS_NO_PATHCONV=1

NETWORK=agent-network

docker network rm "$NETWORK"
