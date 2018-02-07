$eventHubString = get-content eventhub.txt
foreach ($subscription in Get-AzureRmSubscription ) {
    Write-Host $subscription.SubscriptionName
    Select-AzureRmSubscription -Subscription $subscription.id
    $logging=$FALSE
    foreach ($logpro in Get-AzureRmLogProfile) {
        Write-Host $logpro.ServiceBusRuleId, $logpro.Name
        $logging=$TRUE
    }
    if (! $logging) {
        # creating the log profile here
        Write-Host "this sub does not have a logging profile; we should create it"
        #Add-AzureRmLogProfile -Name default -ServiceBusRuleId $eventHubString -RetentionInDays 0 -Location "Centralus,northcentralus,southcentralus,westus,eastus,eastus2,global"
    }
}
