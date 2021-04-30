#!/bin/sh
## Usage: ./idam-user-token.sh [user] [password]
##
## Options:
##    - username: Role assigned to user in generated token. Default to `ccd.docker.default@hmcts.net`.
##    - password: ID assigned to user in generated token. Default to `Pa55word11`.
##
## Returns a valid IDAM user token for the given username and password.

IMPORTER_USERNAME=${1:-ccd.docker.default@hmcts.net}
IMPORTER_PASSWORD=${2:-Pa55word11}
IDAM_URI="http://localhost:5000"
REDIRECT_URI="http://localhost:3451/oauth2redirect"
CLIENT_ID="ccd_gateway"
CLIENT_SECRET="ccd_gateway_secret"
SCOPE="openid%20profile%20roles"

curl --silent -H "Content-Type: application/x-www-form-urlencoded" \
    -XPOST "${IDAM_URI}/o/token?grant_type=password&redirect_uri=["http://localhost:3002/oauth2/callback", "http://localhost:3451/oauth2redirect"]&client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}&username=${IMPORTER_USERNAME}&password=${IMPORTER_PASSWORD}&scope=${SCOPE}" -d "" | docker run --rm --interactive stedolan/jq -r .access_token