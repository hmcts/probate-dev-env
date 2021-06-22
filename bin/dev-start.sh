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
  sleep 5;
done

# Start all other images
echo "Starting dependencies..."
docker-compose ${COMPOSE_FILE} up -d
$BIN_FOLDER/wiremock.sh
echo "LOCAL ENVIRONMENT SUCCESSFULLY STARTED"
echo "Environment is ready, other than some fee updates which may take a while."
echo "Waiting to update fees..."

UPDATE_COUNT=0;
UPDATE_RESULT="";
until [[ "$UPDATE_RESULT" == "UPDATE 1" || "$UPDATE_COUNT" == 60 ]]
do
  if [ "$UPDATE_RESULT" == "" ]
  then
    echo "attempting copies fee keyword update";
  else 
    echo "retrying copies fee keyword update";
  fi

  UPDATE_RESULT=$(psql -h localhost --username postgres -d fees_register -p 5050 -c "UPDATE public.fee SET keyword = 'NewFee' WHERE code = 'FEE0003'";);
  echo $UPDATE_RESULT
  if [ "$UPDATE_RESULT" != "UPDATE 1" ]
  then
    if [ "$UPDATE_RESULT" == "" ]
    then 
      UPDATE_RESULT="ERROR";
    fi
    sleep 10;
    ((UPDATE_COUNT+=1));
  else
    UPDATE_COUNT=60;
  fi
done

echo "...Fees can now be updated."

echo "Inserting new fees data..."

psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO fee (application_type,channel_type,code,creation_time,event_type,fee_number,fee_type,jurisdiction1,jurisdiction2,keyword,last_updated,service,unspecified_claim_amount) values ('all','default','FEE0501',now(),'miscellaneous',501,'FixedFee','family','probate registry','Caveat',now(),'probate',false)";
psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO amount (amount_type,creation_time,last_updated) VALUES ('FlatAmount',now(),now())";
psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO flat_amount(id, amount) VALUES ((SELECT MAX( id ) FROM amount a ), 3)";
psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO fee_version (description,status,valid_from,valid_to,version,amount_id,fee_id,direction_type,fee_order_name,memo_line,natural_account_code,si_ref_id,statutory_instrument,approved_by,author) VALUES ('Application for the entry or extension of a caveat',1,'2011-04-03 00:00:00.000',NULL,1,(SELECT MAX( id ) FROM amount a ),(SELECT MAX(id) from fee),'cost recovery','Non-Contentious Probate Fees','RECEIPT OF FEES - Family misc probate','4481102173','4','2011 No 588 ','126175','126172')";

psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO fee (application_type,channel_type,code,creation_time,event_type,fee_number,fee_type,jurisdiction1,jurisdiction2,keyword,last_updated,service,unspecified_claim_amount) values ('all','default','FEE0500',now(),'issue',500,'FixedFee','family','probate registry','SAL5K',now(),'probate',false)";
psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO amount (amount_type,creation_time,last_updated) VALUES ('FlatAmount',now(),now())";
psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO flat_amount(id, amount) VALUES ((SELECT MAX( id ) FROM amount a ), 0)";
psql -h localhost --username postgres -d fees_register -p 5050 -c "INSERT INTO fee_version (description,status,valid_from,valid_to,version,amount_id,fee_id,direction_type,fee_order_name,memo_line,natural_account_code,si_ref_id,statutory_instrument,approved_by,author) VALUES ('Application for Gor Fee less than 5000',1,'2011-04-03 00:00:00.000',NULL,1,(SELECT MAX( id ) FROM amount a ),(SELECT MAX(id) from fee),'cost recovery','Non-Contentious Probate Fees','RECEIPT OF FEES - Family misc probate','4481102173','4','2011 No 588 ','126175','126172')";
echo "...insert fees completed"

echo "Updating Fees keyword, and amounts..."
psql -h localhost --username postgres -d fees_register -p 5050 -c "UPDATE public.fee SET keyword = 'GrantWill' WHERE code = 'FEE0003'";
psql -h localhost --username postgres -d fees_register -p 5050 -c "UPDATE public.fee SET keyword = 'PA' WHERE code = 'FEE0226'";
psql -h localhost --username postgres -d fees_register -p 5050 -c "UPDATE public.fee SET keyword = 'PAL5K' WHERE id = 1";
psql -h localhost --username postgres -d fees_register -p 5050 -c "UPDATE public.fee SET keyword = 'SA' WHERE code = 'FEE0219'";
psql -h localhost --username postgres -d fees_register -p 5050 -c "UPDATE volume_amount SET amount = '1.5' WHERE id = (SELECT id FROM amount WHERE amount_type = 'VolumeAmount' ORDER BY id LIMIT 1)";
psql -h localhost --username postgres -d fees_register -p 5050 -c "UPDATE flat_amount SET amount = '1.5' WHERE id = '1'";
echo "...Updated fees"

