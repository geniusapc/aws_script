#!/bin/bash

# This script can be used to retreive secret key stored on aws parameter store.
# Note:
#       Ensure that AWS and jq are installed on the host machine

echo "Preparing script..."

DIR="/home/ubuntu/project"
cd ${DIR}


rm -f chunk_env_variable* env_variable.json
touch env_variable.json

# NOTE: Request limit  for AWS parameter store is 10. so if you have more than 10 environment variable, you have to make multiple calls
#  make sure to change the region  to the region where your keys are stored
echo "Reading from parameter store..."

aws ssm get-parameters --name \
"/PROJECT/SERVER/PROD/ENV_VARIABLE_1" \
"/PROJECT/SERVER/PROD/ENV_VARIABLE_2" \
 --region eu-central-1 | jq -r '.Parameters | .[] | {Name:.Name, Value:.Value}' >> chunk_env_variable1.json

aws ssm get-parameters --name \
"/PROJECT/SERVER/PROD/ENV_VARIABLE_11" \
"/PROJECT/SERVER/PROD/ENV_VARIABLE_12" \
 --region eu-central-1 | jq -r '.Parameters | .[] | {Name:.Name, Value:.Value}' >> chunk_env_variable2.json



echo  "Writing parameter store variables to json file ..."
jq -s 'flatten' chunk_env_variable*.json >  env_variable.json


ENV_VARIABLE_1=$(cat env_variable.json | jq -r '.[] | select(.Name=="/PROJECT/SERVER/PROD/ENV_VARIABLE_1") | .Value')
ENV_VARIABLE_2=$(cat env_variable.json | jq -r '.[] | select(.Name=="/PROJECT/SERVER/PROD/ENV_VARIABLE_2") | .Value')
ENV_VARIABLE_11=$(cat env_variable.json | jq -r '.[] | select(.Name=="/PROJECT/SERVER/PROD/ENV_VARIABLE_11") | .Value')
ENV_VARIABLE_12=$(cat env_variable.json | jq -r '.[] | select(.Name=="/PROJECT/SERVER/PROD/ENV_VARIABLE_12") | .Value')


rm -f chunk_env_variable*

echo "creating env file ...."
# Dir to store the secret keys
ENV_PATH="./.env"
rm -f "$ENV_PATH" && touch  "$ENV_PATH"

cat << EOF > $ENV_PATH
ENV_VARIABLE_1=$ENV_VARIABLE_1
ENV_VARIABLE_2=$ENV_VARIABLE_2
ENV_VARIABLE_11=$ENV_VARIABLE_12
ENV_VARIABLE_12=$ENV_VARIABLE_12
EOF

echo "Created .env file!!!"