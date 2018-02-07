foreach ($subby in Get-AzureRmSubscription ) {
    Select-AzureRmSubscription -Subscription $subby.id
    foreach ($nsg in Get-AzureRmNetworkSecurityGroup) {
        $loc=$nsg.Location
        $networkwatcher = Get-AzurermNetworkWatcher -ResourceGroupName NetworkWatcherRg -Name "NetworkWatcher_$loc"
        #Get-AzureRmNetworkWatcherFlowLogStatus -NetworkWatcher $networkwatcher -TargetResourceId $nsg.Id
    }
}