#!/bin/sh

IDAM_URI="http://localhost:5000"
role=$1
description=${2:-Test}

if [ -z "$role" ]
  then
    echo "Usage: ./idam-role.sh role [role] [description]"
    exit 1
fi
authToken=$(curl -s -H 'Content-Type: application/x-www-form-urlencoded' -XPOST "${IDAM_URI}/loginUser?username=idamOwner@hmcts.net&password=Ref0rmIsFun" | docker run --rm --interactive stedolan/jq -r .api_auth_token)

echo "\nCreating role with:\nName: ${role}\n"


curl --silent --show-error ${IDAM_URI}/roles \
   -H 'Content-Type: application/json' \
   -H "Authorization: AdminApiAuthToken ${authToken}" \
   -d '{
        "assignableRoles": [],
        "conflictingRoles": [],
        "description": "'"${role}"'",
        "id": "'"${role}"'",
        "linkedRoles": [],
        "name": "'"${role}"'"
      }'
