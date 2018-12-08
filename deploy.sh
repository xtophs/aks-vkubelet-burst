#!/bin/bash

set -e 
#set -x

. azure.env

az group create --name ${RG} --location ${LOCATION}

#create new service principal if it doesn't exist
if [ ! -f ./sp.env ]; then
    if [ ! -f ~/.azure/aksServicePrincipal.json ]; then
        echo no existing AKS principal, create a new one
        sp=$(az ad sp create-for-rbac --skip-assignment)
        echo Service Principal ${sp}

        cat << EOF > sp.env
spname=$( echo ${sp} | jq -r .name )
appId=$( echo ${sp} | jq -r .appId )
pwd=$( echo ${sp} | jq -r .password )
tenantId=$(az account show --query tenantId -o tsv)
EOF
    else
        echo Use the existing AKS Principal
        cat << EOF > sp.env
spname=$(cat ~/.azure/aksServicePrincipal.json | jq -r '.[].service_principal' | head -n1)
appId=$(cat ~/.azure/aksServicePrincipal.json | jq -r '.[].service_principal' | head -n1)
pwd=$(cat ~/.azure/aksServicePrincipal.json | jq -r '.[].client_secret' | head -n1)
tenantId=$(az account show --query tenantId -o tsv)
EOF
    cat sp.env
    fi
else
    echo Found existing sp.env
    cat sp.env
fi

. sp.env

. deploy-acr.sh
. deploy-vnet.sh
. deploy-aks.sh
. deploy-vkubelet.sh

echo Inspect container status with 
echo kubectl get pods -o wide
echo az container list
echo
echo When ready, deploy the virtual kubelet test pods
echo kubectl create -f virtual-kubelet-test.yaml











