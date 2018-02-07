$eventHubString = get-content eventhub.txt
foreach ($subby in Get-AzureRmSubscription ) {
    Write-Host $subby.SubscriptionName
    Select-AzureRmSubscription -Subscription $subby.id
    $logging=$FALSE
    foreach ($logpro in Get-AzureRmLogProfile) {
        Write-Host $logpro.ServiceBusRuleId, $logpro.Name
        $logging=$TRUE

    }
    if (! $logging) {
        # creating the log profile here
        Write-Host 'Add-AzureRmLogProfile -Name default -ServiceBusRuleId $eventHubString -RetentionInDays 0 -Location "centralus,northcentralus,southcentralus,westus,eastus,eastus2,global"'
    }
}
