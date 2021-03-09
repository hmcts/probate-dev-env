#!/bin/bash

# Set variables
COMPOSE_FILE=""
BIN_FOLDER=$($(dirname "$0")/probate-dev-env-realpath)

echo "Logging into ACR..."
az acr login --name hmctspublic --subscription 8999dec3-0104-4a27-94ee-6588559729d1
az acr login --name hmctsprivate --subscription 8999dec3-0104-4a27-94ee-6588559729d1

echo "Pulling docker images..."
docker-compose ${COMPOSE_FILE} pull
docker-compose ${COMPOSE_FILE} build

echo "Starting databases..."
docker-compose ${COMPOSE_FILE} up -d shared-db shared-database

echo "Starting ForgeRock..."
docker-compose ${COMPOSE_FILE} up -d fr-am fr-idm

echo "Starting IDAM..."
docker-compose ${COMPOSE_FILE} up -d sidam-api

echo "Fetching latest Probate CCD definition file ${BIN_FOLDER}"
curl https://codeload.github.com/hmcts/probate-back-office/tar.gz/master | tar -xz  -C $BIN_FOLDER/../ --strip=1 probate-back-office-master/ccdImports/configFiles

# Set up IDAM client with services and roles
echo "Setting up IDAM client..."
until curl http://localhost:5000/health
do
  echo "Waiting for IDAM";
  sleep 10;
done

$BIN_FOLDER/idam-client-setup.sh

# Start all other images
echo "Starting dependencies..."
docker-compose ${COMPOSE_FILE} up -d fees-api ccd-data-store-api ccd-definition-store-api ccd-elasticsearch

# Fees API migrations appear to be broken so it fails to boot first time round
docker-compose ${COMPOSE_FILE} restart fees-api

echo "Setting up CCD roles..."
until curl http://localhost:4451/health
do
  echo "Waiting for CCD";
  sleep 10;
done

$BIN_FOLDER/ccd-add-all-roles.sh
$BIN_FOLDER/../ccdImports/conversionScripts/createAllXLS.sh probate-back-office:4104
$BIN_FOLDER/../ccdImports/conversionScripts/importAllXLS.sh

docker-compose ${COMPOSE_FILE} stop

echo "LOCAL ENVIRONMENT SUCCESSFULLY CREATED"
echo "Start the environment with npx @hmcts/probate-dev-env"
