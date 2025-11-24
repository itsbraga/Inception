#!/bin/sh

# Stop all containers
docker stop $(docker ps)

# Remove all stopped containers
docker container prune --force

# Remove all unused images (not just dangling ones)
docker image prune --all --force

# Show remaining disk usage
docker system df
