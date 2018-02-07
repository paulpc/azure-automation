# iterating throught the subscriptions
foreach ($subby in Get-AzureRmSubscription ) {
    Select-AzureRmSubscription -Subscription $subby.id
    # switching to the sub
    $logpro=Get-AzureRmLogProfile
    $logpro
}