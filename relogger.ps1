$eventHubString = get-content eventhub.txt
foreach ($subby in Get-AzureRmSubscription ) {
    Write-Host $subby.SubscriptionName
    Select-AzureRmSubscription -Subscription $subby.id
    $logpro=Get-AzureRmLogProfile
    $logpro.Name
    if ($logpro) {
        # powershell sucks - so let's remove the existing logging profile
        Write-Host "Remove-AzureRmLogProfile -Name" $logpro.Name
    }

    # creating the log profile here
    Write-Host "Add-AzureRmLogProfile -Name default -ServiceBusRuleId $eventHubString -RetentionInDays 0 -Location 'centralus,northcentralus,southcentralus,westus,eastus,eastus2,global'"
}
