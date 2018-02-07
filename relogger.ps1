$eventHubString = get-content eventhub.txt
foreach ($subscription in Get-AzureRmSubscription ) {
    echo $subscription.SubscriptionName
    Select-AzureRmSubscription -Subscription $subscription.id
    $logging=False
    foreach ($logpro in Get-AzureRmLogProfile) {
        echo $logpro.ServiceBusRuleId, $logpro.Name
        $logging=True
    }
    if (not $logging) {
        # creating the log profile here
        echo "this sub does not have a logging profile; we should create it"
        #Add-AzureRmLogProfile -Name default -ServiceBusRuleId $eventHubString -RetentionInDays 0 -Location "Centralus,northcentralus,southcentralus,westus,eastus,eastus2,global"
    }
}