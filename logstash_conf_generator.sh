#/bin/bash
echo "input {" > logstash.conf
for subscription in `az account list --query [*].id --output tsv`; do
  echo $subscription
  az account set -s $subscription
  for store in `az storage account list -g NetworkWatcherRG --query [*].name --output tsv`; do
    echo $store
    blobkey=`az storage account keys list --resource-group NetworkWatcherRG --account-name $store --output tsv | grep key1 | cut -f 3`
    cat << INPUTBLOB | tee -a logstash.conf
azureblob
     {
         storage_account_name => "$store"
         storage_access_key => "$blobkey"
         container => "insights-logs-networksecuritygroupflowevent"
         codec => "json"
         file_head_bytes => 12
         file_tail_bytes => 2
         add_field => {
             "[fields][logsource]" => "azure-nsg"
         }

     }
INPUTBLOB
  done
done
echo "}" >> logstash.conf
