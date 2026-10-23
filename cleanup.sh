#!/bin/sh

set -e
export MSYS_NO_PATHCONV=1

docker ps -aq --filter label=project=chinook-agent | xargs -r docker rm -f
# The gateway starts this container itself, so it never gets our project label.
# The gateway marks it with docker-mcp=true, so we remove it by that label instead.
docker ps -aq --filter label=docker-mcp=true | xargs -r docker rm -f
docker volume ls -q --filter label=project=chinook-agent | xargs -r docker volume rm
docker network ls -q --filter label=project=chinook-agent | xargs -r docker network rm
docker images -q --filter label=project=chinook-agent | xargs -r docker rmi