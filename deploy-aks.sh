#!/bin/bash

set -e

. sp.env

subnetId=$(az network vnet subnet show \
    --resource-group ${RG} \
    --vnet-name $VNET_NAME \
    --name $CLUSTER_SUBNET_NAME \
    --query id -o tsv)

echo Creating AKS cluster ${CLUSTER_NAME}

az aks create \
    --resource-group ${RG} \
    --name ${CLUSTER_NAME} \
    --node-vm-size Standard_D2_v2 \
    --node-count 1 \
    --service-principal $appId \
    --client-secret ${pwd} \
    --generate-ssh-keys \
    --network-plugin azure \
    --service-cidr 10.0.0.0/16 \
    --dns-service-ip $KUBE_DNS_IP \
    --docker-bridge-address 172.17.0.1/16 \
    --vnet-subnet-id ${subnetId} \
   
# get cluster credentials and make new cluster default for kubectl
az aks get-credentials -n ${CLUSTER_NAME} -g ${RG} 

# upgrade cluster if you want to use 
# dnsConfig 
az aks upgrade --kubernetes-version 1.10.9 \
    --resource-group ${RG} \
    --name ${CLUSTER_NAME} \
    --no-wait

# TODO wait for upgrade to complete


# create kubernetes secret to access ACR
kubectl create secret docker-registry regcred \
    --docker-server ${ACR_NAME}.azurecr.io \
    --docker-username=${appId} \
    --docker-password=${pwd} \
    --docker-email=a@b.com

