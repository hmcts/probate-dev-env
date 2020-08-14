#!/bin/bash

# Set variables
COMPOSE_FILE=""

echo "Starting databases..."
docker-compose ${COMPOSE_FILE} up -d shared-db shared-database

echo "Starting ForgeRock..."
docker-compose ${COMPOSE_FILE} up -d fr-am fr-idm

echo "Starting IDAM..."
docker-compose ${COMPOSE_FILE} up -d sidam-api

echo "Waiting for IDAM to start"
until curl http://localhost:5000/health
do
  echo "Waiting for IDAM";
  sleep 10;
done

# Start all other images
echo "Starting dependencies..."
docker-compose ${COMPOSE_FILE} up -d

echo "LOCAL ENVIRONMENT SUCCESSFULLY STARTED"
