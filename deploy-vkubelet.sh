#!/bin/bash

export VK_RELEASE=virtual-kubelet-latest

# get cluster URL
export MASTER_URI=$(kubectl cluster-info | head -n1 | cut -d ' ' -f 6 | cut -d '/' -f 3 | cut -d ':' -f 1)

RELEASE_NAME=virtual-kubelet
NODE_NAME=virtual-kubelet
CHART_URL=https://github.com/virtual-kubelet/virtual-kubelet/raw/master/charts/$VK_RELEASE.tgz

#kubectl create -f tiller-rbac.yaml
#helm init --upgrade --service-account=tiller

helm install "$CHART_URL" --name "$RELEASE_NAME" \
  --set provider=azure \
  --set providers.azure.targetAKS=true \
  --set providers.azure.vnet.enabled=true \
  --set providers.azure.vnet.subnetName=$ACI_SUBNET_NAME \
  --set providers.azure.vent.subnetCidr=$ACI_SUBNET_RANGE \
  --set providers.azure.vnet.clusterCidr=$CLUSTER_SUBNET_RANGE \
  --set providers.azure.vnet.kubeDnsIp=$KUBE_DNS_IP \
  --set providers.azure.masterUri=$MASTER_URI

