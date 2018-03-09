#!/bin/bash
for subscription in `az account list --query [*].id --output tsv`; do
  echo $subscription
  az account set -s $subscription
  for nsg in `az network nsg list --query [*].id --out tsv`; do
      # checking if enabled
      #enabled=`az network watcher flow-log show --nsg $nsg | grep '"enabled": true'`
      #if [ -z "$enabled" ]; then
        echo $nsg
        location=`az network nsg show --ids $nsg | grep location | cut -d '"' -f 4`
        blobname=`echo $subscription | cut -d "-" -f 1`"$location"
        az network watcher flow-log configure --nsg $nsg --enabled true --storage-account $blobname -g NetworkWatcherRG --retention 365
        #az network watcher flow-log show --nsg $nsg
      #fi
  done
done
