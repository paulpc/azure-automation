#!/bin/bash
for subscription in `az account list --query [*].id --output tsv`; do
  echo $subscription
  az account set -s $subscription
  for nsg in `az network nsg list --query [*].id --out tsv`; do
      # checking if enabled
      echo $nsg
      az network watcher flow-log show --nsg $nsg
  done
done
