#!/bin/sh

IMPORTER_USERNAME=${1:-ccd.docker.default@hmcts.net}
IMPORTER_PASSWORD=${2:-Pa55word11}
IDAM_URI="http://localhost:5000"
REDIRECT_URI="http://localhost:3451/oauth2redirect"
CLIENT_ID="ccd_gateway"
CLIENT_SECRET="ccd_gateway_secret"
XUI_CLIENT_ID="xuiwebapp"
XUI_CLIENT_SECRET=${OAUTH2_CLIENT_SECRET}
BIN_FOLDER=$($(dirname "$0")/probate-dev-env-realpath)

XUI_ROLES_ARR=("XUI-Admin" "XUI-SuperUser" "caseworker" "caseworker-probate" "caseworker-probate-solicitor" "ccd-import" "caseworker-probate-superuser" "payment")
XUI_ROLES_STR=$(printf "\"%s\"," "${XUI_ROLES_ARR[@]}")
XUI_ROLES="[${XUI_ROLES_STR%?}]"

authToken=$(curl -v -H 'Content-Type: application/x-www-form-urlencoded' -XPOST "${IDAM_URI}/loginUser?username=idamOwner@hmcts.net&password=Ref0rmIsFun" | jq -r .api_auth_token)
HEADERS=(-H "Authorization: AdminApiAuthToken ${authToken}" -H "Content-Type: application/json")
echo "authtoken is ${authToken}"

#Create a ccd gateway client
curl -XPOST \
  ${IDAM_URI}/services \
 -H "Authorization: AdminApiAuthToken ${authToken}" \
 -H "Content-Type: application/json" \
 -d '{ "activationRedirectUrl": "", "allowedRoles": ["ccd-import", "caseworker", "caseworker-probate", "caseworker-probate", "caseworker-probate-issuer", "caseworker-probate-solicitor", "caseworker-probate-authoriser", "caseworker-probate-systemupdate", "caseworker-probate-scheduler", "caseworker-probate-caseofficer", "caseworker-probate-caseadmin", "caseworker-probate-registrar", "caseworker-probate-superuser", "caseworker-probate-charity", "payment", "caseworker-probate-bulkscan" ], "description": "ccd_gateway", "label": "ccd_gateway", "oauth2ClientId": "ccd_gateway", "oauth2ClientSecret": "ccd_gateway_secret", "oauth2RedirectUris": ["http://localhost:3451/oauth2redirect", "http://localhost:3000/oauth2/callback" ], "oauth2Scope": "string", "onboardingEndpoint": "string", "onboardingRoles": ["ccd-import", "caseworker", "caseworker-probate", "caseworker-probate", "caseworker-probate-issuer", "caseworker-probate-solicitor", "caseworker-probate-authoriser", "caseworker-probate-systemupdate", "caseworker-probate-caseofficer", "caseworker-probate-caseadmin", "caseworker-probate-registrar", "caseworker-probate-superuser", "caseworker-probate-charity", "payment", "caseworker-probate-bulkscan" ], "selfRegistrationAllowed": true}'

echo "Setup xui client"
# Create a xui client
curl -s -o /dev/null -XPOST "${HEADERS[@]}" ${IDAM_URI}/services \
 -d '{ "activationRedirectUrl": "", "allowedRoles": '"${XUI_ROLES}"', "description": "'${XUI_CLIENT_ID}'", "label": "'${XUI_CLIENT_ID}'", "oauth2ClientId": "'${XUI_CLIENT_ID}'", "oauth2ClientSecret": "'${XUI_CLIENT_SECRET}'", "oauth2RedirectUris": '${REDIRECT_URI}', "oauth2Scope": "profile openid roles manage-user create-user", "onboardingEndpoint": "string", "onboardingRoles": '"${XUI_ROLES}"', "selfRegistrationAllowed": true}'


#Create all the role
$BIN_FOLDER/idam-role.sh caseworker
$BIN_FOLDER/idam-role.sh caseworker-probate
$BIN_FOLDER/idam-role.sh caseworker-probate-issuer
$BIN_FOLDER/idam-role.sh caseworker-probate-solicitor
$BIN_FOLDER/idam-role.sh caseworker-probate-authoriser
$BIN_FOLDER/idam-role.sh caseworker-probate-systemupdate
$BIN_FOLDER/idam-role.sh caseworker-probate-caseofficer
$BIN_FOLDER/idam-role.sh caseworker-probate-caseadmin
$BIN_FOLDER/idam-role.sh caseworker-probate-registrar
$BIN_FOLDER/idam-role.sh caseworker-probate-superuser
$BIN_FOLDER/idam-role.sh caseworker-probate-bulkscan
$BIN_FOLDER/idam-role.sh caseworker-probate-scheduler
$BIN_FOLDER/idam-role.sh caseworker-probate-charity
$BIN_FOLDER/idam-role.sh payment
$BIN_FOLDER/idam-role-assignable.sh ccd-import

echo "Setup xui roles"
# Create roles in idam
for role in "${XUI_ROLES_ARR[@]}"; do
  curl -s -o /dev/null -XPOST ${IDAM_URI}/roles "${HEADERS[@]}" \
    -d '{"id": "'${role}'","name": "'${role}'","description": "'${role}'","assignableRoles": [],"conflictingRoles": []}'
done

#Assign all the roles to the ccd_gateway client
curl -XPUT \
  ${IDAM_URI}/services/ccd_gateway/roles \
 -H "Authorization: AdminApiAuthToken ${authToken}" \
 -H "Content-Type: application/json" \
 -d '["ccd-import", "caseworker", "caseworker-probate", "caseworker-probate", "caseworker-probate-issuer", "caseworker-probate-solicitor", "caseworker-probate-authoriser", "caseworker-probate-systemupdate", "caseworker-probate-caseofficer", "caseworker-probate-caseadmin", "caseworker-probate-registrar", "caseworker-probate-superuser", "caseworker-probate-charity", "caseworker-probate-scheduler", "payment"]'

echo "Setup xui client roles"
# Assign all the roles to the client
curl -s -o /dev/null -XPUT "${HEADERS[@]}" ${IDAM_URI}/services/${XUI_CLIENT_ID}/roles -d "${XUI_ROLES}"