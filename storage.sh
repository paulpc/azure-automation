#/bin/bash
tags=`cat tags.txt`
for subscription in `az account list --query [*].id --output tsv`; do
  echo $subscription
  az account set -s $subscription
  for location in `az network nsg list --output table | cut -f 1 -d " " | sort -u | grep -v "\-\-\-\-" | grep -v Location`; do
    echo $location
    blobname=`echo $subscription | cut -d "-" -f 1`"$location"
    echo $networkgr
    today=`date +%m/%d/%Y`
    az storage account create --kind BlobStorage --sku=Standard_LRS -l $location -n $blobname -g NetworkWatcherRG --access-tier Hot --https-only true --tags $tags
  done
done
