#!/bin/bash

az network vnet create \
--resource-group ${RG} \
--name $VNET_NAME \
--address-prefixes $VNET_RANGE \
--subnet-name $CLUSTER_SUBNET_NAME \
--subnet-prefix $CLUSTER_SUBNET_RANGE

az network vnet subnet create \
    --resource-group ${RG} \
    --vnet-name $VNET_NAME \
    --name $ACI_SUBNET_NAME \
    --address-prefix $ACI_SUBNET_RANGE

export vnetId=$(az network vnet show \
    --resource-group ${RG} \
    --name $VNET_NAME \
    --query id \
    -o tsv)

set +e

# TODO consolidate into utility function
while true; do
    # CHANGE THIS TO READER LATER
    az role assignment create \
        --scope ${vnetId} \
        --assignee ${appId} \
        --role "Contributor"
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
