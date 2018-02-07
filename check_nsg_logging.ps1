foreach ($subby in Get-AzureRmSubscription ) {
    Select-AzureRmSubscription -Subscription $subby.id
    foreach ($nsg in Get-AzureRmNetworkSecurityGroup) {
        $networkwatcher = Get-AzurermNetworkWatcher -ResourceGroupName NetworkWatcherRg -Name "NetworkWatcher_$nsg.Location"
        Get-AzureRmNetworkWatcherFlowLogStatus -NetworkWatcher $networkwatcher -TargetResourceId $nsg.Id
    }
}