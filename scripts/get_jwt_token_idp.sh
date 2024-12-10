#!/bin/bash

# Keycloak configuration
# 
case $1 in
    "dev")
        URL="dev.idp.dubber.net"
        ;;
    "qa")
        URL="qa.idp.dubber.net"
        ;;
    "staging")
        URL="staging.idp.dubber.net"
        ;;
    "au")
        URL="idp.apac.dubber.net"
        ;;
    *)
        echo "Usage: $0 [dev|qa|staging|prod]"
        exit 1
        ;;
esac

URL=$1
KEYCLOAK_URL="https://$URL/"
REALM="dubber"
CLIENT_ID="dubber-spa" #au_portal
CLIENT_SECRET="3d32404b-04d4-458a-abe8-c90abfbfc444"
USERNAME="pvt+alex+aadubtm_insights@dubber.net"
PASSWORD="Dtest@123"
# USERNAME="hulk@dubber.net"

# Construct token endpoint URL
TOKEN_URL="${KEYCLOAK_URL}/auth/realms/$REALM/protocol/openid-connect/token"

# Make the token request
echo "Requesting token..."
response=$(curl -s -X POST "${TOKEN_URL}" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "client_id=${CLIENT_ID}" \
    -d "client_secret=${CLIENT_SECRET}" \
    -d "grant_type=password" \
    -d "username=${USERNAME}" \
    -d "password=${PASSWORD}")

# Check if the request was successful
if echo "$response" | grep -q "access_token"; then
    echo "Authentication successful!"
    echo
    echo "Access Token:"
    echo "$response" | jq -r .access_token
    
    echo -e "\nRefresh Token:"
    echo "$response" | jq -r .refresh_token
    
    echo -e "\nExpires in:"
    echo "$response" | jq -r .expires_in
else
    echo "Error obtaining token:"
    echo "$response" | jq '.' || echo "$response"
fi
