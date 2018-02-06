#!/bin/bash

today=`date +%m/%d/%Y`
for subscription in `az account list --query [*].id --output tsv`; do
    echo $subscription
    az account set -s $subscription
    az monitor log-profiles list --query [*].serviceBusRuleId
done
