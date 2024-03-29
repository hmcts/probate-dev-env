#!/bin/sh

IMPORTER_USERNAME=${1:-ccd.docker.default@hmcts.net}
IMPORTER_PASSWORD=${2:-Pa55word11}
IDAM_URI="http://localhost:5000"
REDIRECT_URI="http://localhost:3451/oauth2redirect"
CLIENT_ID="ccd_gateway"
CLIENT_SECRET="ccd_gateway_secret"
XUI_CLIENT_ID="xui_webapp"
XUI_CLIENT_SECRET="xui_webapp_secret"
BIN_FOLDER=$($(dirname "$0")/probate-dev-env-realpath)

authToken=$(curl -s -X POST "${IDAM_URI}/loginUser" -H "accept: application/json" -H "Content-Type: application/x-www-form-urlencoded" -d "password=Ref0rmIsFun&username=idamOwner@hmcts.net" | docker run --rm --interactive stedolan/jq -r .api_auth_token)

echo "authtoken is ${authToken}"

#Create a ccd gateway client
curl -XPOST \
  ${IDAM_URI}/services \
 -H "Authorization: AdminApiAuthToken ${authToken}" \
 -H "Content-Type: application/json" \
 -d '{ "activationRedirectUrl": "", "allowedRoles": ["ccd-import", "caseworker", "caseworker-probate", "caseworker-probate", "caseworker-probate-issuer", "caseworker-probate-solicitor", "caseworker-probate-authoriser", "caseworker-probate-systemupdate", "caseworker-probate-scheduler", "caseworker-probate-caseofficer", "caseworker-probate-caseadmin", "caseworker-probate-registrar", "caseworker-probate-superuser", "caseworker-probate-charity", "payment", "caseworker-probate-bulkscan" ], "description": "ccd_gateway", "label": "ccd_gateway", "oauth2ClientId": "ccd_gateway", "oauth2ClientSecret": "ccd_gateway_secret", "oauth2RedirectUris": ["http://localhost:3451/oauth2redirect", "http://localhost:3000/oauth2/callback" ], "oauth2Scope": "string", "onboardingEndpoint": "string", "onboardingRoles": ["ccd-import", "caseworker", "caseworker-probate", "caseworker-probate", "caseworker-probate-issuer", "caseworker-probate-solicitor", "caseworker-probate-authoriser", "caseworker-probate-systemupdate", "caseworker-probate-caseofficer", "caseworker-probate-caseadmin", "caseworker-probate-registrar", "caseworker-probate-superuser", "caseworker-probate-charity", "payment", "caseworker-probate-bulkscan" ], "selfRegistrationAllowed": true}'

echo "Setup xui client"
# Create a xui client
curl -XPOST \
  ${IDAM_URI}/services \
 -H "Authorization: AdminApiAuthToken ${authToken}" \
 -H "Content-Type: application/json" \
 -d '{ "activationRedirectUrl": "", "allowedRoles": ["ccd-import", "caseworker", "caseworker-probate", "caseworker-probate-solicitor", "caseworker-probate-superuser", "pui-case-manager", "pui-user-manager"], "description": "xui_webapp", "label": "xui_webapp", "oauth2ClientId": "xui_webapp", "oauth2ClientSecret": "xui_webapp_secret", "oauth2RedirectUris": ["http://localhost:3455/oauth2/callback"], "oauth2Scope": "profile openid roles manage-user create-user search-user", "onboardingEndpoint": "string", "onboardingRoles": ["ccd-import", "caseworker", "caseworker-probate", "caseworker-probate-solicitor", "caseworker-probate-superuser","pui-case-manager", "pui-user-manager" ], "selfRegistrationAllowed": true}'

echo "Setup am_role_assignment client"
#Create a am_role_assignment
curl -XPOST \
  ${IDAM_URI}/services \
 -H "Authorization: AdminApiAuthToken ${authToken}" \
 -H "Content-Type: application/json" \
 -d '{ "activationRedirectUrl": "", "allowedRoles": [], "description": "am_role_assignment", "label": "am_role_assignment", "oauth2ClientId": "am_role_assignment", "oauth2ClientSecret": "am_role_assignment_secret", "oauth2RedirectUris": ["http://localhost:4096/oauth2redirect"], "oauth2Scope": "profile openid roles search-user", "selfRegistrationAllowed": false}'

curl -XPOST \
  ${IDAM_URI}/services \
 -H "Authorization: AdminApiAuthToken ${authToken}" \
 -H "Content-Type: application/json" \
 -d '{ "activationRedirectUrl": "", "allowedRoles": [], "description": "ccd_data_store_api", "label": "ccd_data_store_api", "oauth2ClientId": "ccd_data_store_api", "oauth2ClientSecret": "idam_data_store_client_secret", "oauth2RedirectUris": ["http://ccd-data-store-api/oauth2redirect" ], "oauth2Scope": "profile openid roles manage-user", "selfRegistrationAllowed": false}'

echo "Setup aac_manage_case_assignment client"
$BIN_FOLDER/idam-create-service.sh "aac_manage_case_assignment" "aac_manage_case_assignment" "AAAAAAAAAAAAAAAA" "https://manage-case-assignment/oauth2redirect" "false" "profile openid roles manage-user"

echo "Setup xui_mo_webapp client"
$BIN_FOLDER/idam-create-service.sh "xui_mo_webapp" "xui_mo_webapp" "AAAAAAAAAAAAAAAA" "http://localhost:3001/oauth2/callback" "false" "profile openid roles manage-user create-user manage-roles"

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
$BIN_FOLDER/idam-role.sh caseworker-caa
$BIN_FOLDER/idam-role.sh pui-caa
$BIN_FOLDER/idam-role.sh pui-organisation-manager
$BIN_FOLDER/idam-create-caseworker.sh caseworker,caseworker-caa,pui-case-manager,pui-user-manager caa-caseworker@mailnesia.com "Password12" "caa" "caseworker"
$BIN_FOLDER/idam-create-caseworker.sh caseworker,caseworker-probate,caseworker-probate-solicitor,pui-case-manager,pui-user-manager,pui-organisation-manager,pui-caa probatesolicitortestorgman3@gmail.com Probate123 TestOrg3 PBA


# Roles required for XUI
echo ""
echo "Setting up Roles required for XUI..."
$BIN_FOLDER/idam-role.sh pui-case-manager
$BIN_FOLDER/idam-role.sh pui-user-manager
$BIN_FOLDER/xui-add-role.sh caseworker-caa
$BIN_FOLDER/xui-add-role.sh pui-caa
$BIN_FOLDER/xui-add-role.sh pui-organisation-manager

#Assign all the roles to the ccd_gateway client
curl -XPUT \
  ${IDAM_URI}/services/ccd_gateway/roles \
 -H "Authorization: AdminApiAuthToken ${authToken}" \
 -H "Content-Type: application/json" \
 -d '["ccd-import", "caseworker", "caseworker-probate", "caseworker-probate", "caseworker-probate-issuer", "caseworker-probate-solicitor", "caseworker-probate-authoriser", "caseworker-probate-systemupdate", "caseworker-probate-caseofficer", "caseworker-probate-caseadmin", "caseworker-probate-registrar", "caseworker-probate-superuser", "caseworker-probate-charity", "caseworker-probate-scheduler", "payment", "caseworker-caa"]'

#Assign roles to the xui_webapp client
curl -XPUT \
  ${IDAM_URI}/services/xui_webapp/roles \
 -H "Authorization: AdminApiAuthToken ${authToken}" \
 -H "Content-Type: application/json" \
 -d '["ccd-import", "caseworker", "caseworker-probate", "caseworker-probate-solicitor", "caseworker-probate-superuser", "pui-case-manager", "pui-user-manager", "caseworker-caa"]'
