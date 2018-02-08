# reading eventhub settings from the text file - shouldn't make it to github
$eventHubString = get-content eventhub.txt
# iterating throught the subscriptions
foreach ($subby in Get-AzureRmSubscription ) {
    Select-AzureRmSubscription -Subscription $subby.id
    # switching to the sub
    $logpro=Get-AzureRmLogProfile
    # if it has a logging profile, we'll delete it
    if ($logpro) {
        # powershell sucks - so let's remove the existing logging profile
        Remove-AzureRmLogProfile -Name $logpro.Name
    }
    # (re)creating the log profile here
    Add-AzureRmLogProfile -Name default -ServiceBusRuleId $eventHubString -RetentionInDays 0 -Locations "Global","Central US","East US","East US 2","West US","North Central US","South Central US","West Central US","West US 2"
}
