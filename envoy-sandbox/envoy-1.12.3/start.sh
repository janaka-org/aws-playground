#!/bin/sh

docker-compose pull 
# this start merges the compose file so everything is on the same docker network 
docker-compose -f docker-compose-collector-only.yaml -f docker-compose.yaml up --build
docker-compose ps

./generate-request-load.sh