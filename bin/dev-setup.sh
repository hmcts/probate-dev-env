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

echo "Inserting fees and amounts"

psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO fee (application_type,channel_type,code,creation_time,event_type,fee_number,fee_type,jurisdiction1,jurisdiction2,keyword,last_updated,service,unspecified_claim_amount) values ('all','default','FEE0288',now(),'miscellaneous',288,'FixedFee','family','probate registry','MNO',now(),'probate',false)";
psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO amount (amount_type,creation_time,last_updated) VALUES ('FlatAmount',now(),now())";
psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO flat_amount(id, amount) VALUES ((SELECT MAX( id ) FROM amount a ), 3)";
psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO fee_version (description,status,valid_from,valid_to,version,amount_id,fee_id,direction_type,fee_order_name,memo_line,natural_account_code,si_ref_id,statutory_instrument,approved_by,author) VALUES ('Application for the entry or extension of a caveat',1,'2011-04-03 00:00:00.000',NULL,1,(SELECT MAX( id ) FROM amount a ),(SELECT MAX(id) from fee),'cost recovery','Non-Contentious Probate Fees','RECEIPT OF FEES - Family misc probate','4481102173','4','2011 No 588 ','126175','126172')";

echo "Updating Fees keyword, and amounts"

# These updates usually return UPDATE 0 after a --create following a --destroy (creating from scratch).
# This means 0 rows updated. It is unclear as to why the row is not there yet;
# but as a workaround we also run these updates iwhen we dev start.
# If these updates do not occur, functional tests and e2e tests will fail.
UPDATE_RESULT=$(psql -h localhost --username postgres -d fees_register -p 5050 -c "UPDATE public.fee SET keyword = 'NewFee' WHERE code = 'FEE0003'";);
echo $UPDATE_RESULT
UPDATE_RESULT=$(psql -h localhost --username postgres -d fees_register -p 5050 -c \
  "UPDATE volume_amount SET amount = '1.5' WHERE id = (SELECT id FROM amount WHERE amount_type = 'VolumeAmount' ORDER BY id LIMIT 1)";);

echo $UPDATE_RESULT
UPDATE_RESULT=$(psql -h localhost --username postgres -d fees_register -p 5050 -c "UPDATE flat_amount SET amount = '1.5' WHERE id = '1'";);
echo $UPDATE_RESULT

docker-compose ${COMPOSE_FILE} stop

echo "LOCAL ENVIRONMENT SUCCESSFULLY CREATED"
echo "Start the environment with npx @hmcts/probate-dev-env"
