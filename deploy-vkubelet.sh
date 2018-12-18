#!/bin/bash

export VK_RELEASE=virtual-kubelet-latest

# get cluster URL
export MASTER_URI=$(kubectl cluster-info | head -n1 | cut -d ' ' -f 6 | cut -d '/' -f 3 | cut -d ':' -f 1)

RELEASE_NAME=virtual-kubelet
NODE_NAME=virtual-kubelet
CHART_URL=https://github.com/virtual-kubelet/virtual-kubelet/raw/master/charts/$VK_RELEASE.tgz

az extension add \
  --source https://aksvnodeextension.blob.core.windows.net/aks-virtual-node/aks_virtual_node-0.2.0-py2.py3-none-any.whl

az aks enable-addons \
    --resource-group ${RG} \
    --name ${CLUSTER_NAME} \
    --addons virtual-node \
    --subnet-name ${ACI_SUBNET_NAME}

