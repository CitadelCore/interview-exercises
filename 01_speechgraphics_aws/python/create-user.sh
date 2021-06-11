#!/usr/bin/env bash
COGNITO_USER_POOL_ID="eu-west-2_H8V0Ik7wW"
USERNAME="$1"
PASSWORD="ohr1tha*o0thoo9X"
#PASSWORD=$(pwgen -c -y 16 1)

if [[ -z "$USERNAME" ]]; then
    echo "username must be specified"
    exit 1
fi

RESULT=$(aws cognito-idp admin-create-user --user-pool-id "$COGNITO_USER_POOL_ID" --username "$USERNAME")
USER_SUB=$(echo "$RESULT" | jq -r .User.Username)

aws cognito-idp admin-set-user-password --user-pool-id "$COGNITO_USER_POOL_ID" --username "$USER_SUB" --password "$PASSWORD" --permanent
echo "user $USERNAME created with sub $USER_SUB and password $PASSWORD"
