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

echo "LOCAL ENVIRONMENT SUCCESSFULLY STARTED"
echo "Environment is ready, other than some fee updates which may take a while."
echo "Updating fees..."

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

UPDATE_COUNT=0;
UPDATE_RESULT="";
until [[ "$UPDATE_RESULT" == "UPDATE 1" || "$UPDATE_COUNT" == 60 ]]
do
  if [ "$UPDATE_RESULT" == "" ]
  then
    echo "attempting flat_amount amount update";
  else 
    echo "retrying flat_amount amount update";
  fi

  UPDATE_RESULT=$(psql -h localhost --username postgres -d fees_register -p 5050 -c "UPDATE flat_amount SET amount = '1.5' WHERE id = '1'";);
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

UPDATE_COUNT=0;
UPDATE_RESULT="";
until [[ "$UPDATE_RESULT" == "UPDATE 1" || "$UPDATE_COUNT" == 60 ]]
do
  if [ "$UPDATE_RESULT" == "" ]
  then
    echo "attempting volume_amount amount update";
  else 
    echo "retrying volume_amount amount update";
  fi

  UPDATE_RESULT=$(psql -h localhost --username postgres -d fees_register -p 5050 -c "UPDATE volume_amount SET amount = '1.5' WHERE id = '4'";);
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



