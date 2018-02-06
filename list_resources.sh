#!/bin/bash

for subscription in `az account list --query [*].id --output tsv`; do
    echo $subscription
    az account set -s $subscription
    az resource list --output tsv | cut -f 12 | sort -u >> resources.txt
done
