#!/bin/bash

# Set variables
COMPOSE_FILE=""
BIN_FOLDER=$($(dirname "$0")/probate-dev-env-realpath)

echo "Logging into ACR..."
az acr login --name hmctspublic --subscription DCD-CNP-Prod
az acr login --name hmctsprivate --subscription DCD-CNP-Prod

echo "Pulling docker images..."
docker-compose ${COMPOSE_FILE} pull
docker-compose ${COMPOSE_FILE} build

echo "Starting databases..."
docker-compose ${COMPOSE_FILE} up -d shared-db shared-database

echo "Starting ForgeRock..."
docker-compose ${COMPOSE_FILE} up -d fr-am fr-idm

echo "Starting IDAM..."
docker-compose ${COMPOSE_FILE} up -d sidam-api

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

# Set up missing Fees keyword
echo "Setting up Feeds keyword"
until psql -h localhost --username postgres -d fees_register -p 5050 -c "UPDATE public.fee SET keyword = 'NewFee' WHERE code = 'FEE0003'";
do
  echo "Retrying";
  sleep 15;
done

psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO fee (application_type,channel_type,code,creation_time,event_type,fee_number,fee_type,jurisdiction1,jurisdiction2,keyword,last_updated,service,unspecified_claim_amount) values ('all','default','FEE0288',now(),'miscellaneous',288,'FixedFee','family','probate registry','MNO',now(),'probate',false)";
psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO amount (amount_type,creation_time,last_updated) VALUES ('FlatAmount',now(),now())";
psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO flat_amount(id, amount) VALUES ((SELECT MAX( id ) FROM amount a ), 3)";
psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO fee_version (description,status,valid_from,valid_to,"version",amount_id,fee_id,direction_type,fee_order_name,memo_line,natural_account_code,si_ref_id,statutory_instrument,approved_by,author) VALUES ('Application for the entry or extension of a caveat',1,'2011-04-03 00:00:00.000',NULL,1,(SELECT MAX( id ) FROM amount a ),(SELECT MAX(id) from fee),'cost recovery','Non-Contentious Probate Fees','RECEIPT OF FEES - Family misc probate','4481102173','4','2011 No 588 ','126175','126172')";

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
