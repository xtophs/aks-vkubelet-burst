#!/bin/bash
set +e

. sp.env

# az acr create is not idempotent!
# have to delete here ... 
az acr delete -n ${ACR_NAME}

set -e

echo APP ID is ${appId}

az acr create -g ${RG} \
    -n ${ACR_NAME} \
    --sku Basic \
    --admin-enabled false

export acrId=$(az acr show --resource-group ${RG} --name ${ACR_NAME} --query "id" --output tsv)
echo ACR ID is ${acrId}

# it take a bit until the SP is ready for role assignment
# You may get error: Principal XXXX does not exist in the directory YYY.
# try this a few times

set +e

while true; do
    # CHANGE THIS TO READER LATER
    az role assignment create --scope $acrId --assignee ${appId} --role Reader
    status=$?

    if [ $status -ne 0 ]; then
        # Something happened. Let's try again.
        echo "Waiting"
        sleep 200
    else 
        #role assignment succeeded
        break
    fi
done 

set -e 

echo Access to SP ${appId} assigned
