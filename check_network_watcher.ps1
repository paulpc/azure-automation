foreach ($subby in Get-AzureRmSubscription ) {
    Select-AzureRmSubscription -Subscription $subby.id
    Get-AzurermNetworkWatcher -ResourceGroupName NetworkWatcherRg
}