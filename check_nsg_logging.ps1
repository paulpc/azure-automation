foreach ($subby in Get-AzureRmSubscription ) {
    Select-AzureRmSubscription -Subscription $subby.id
    foreach ($nsg in Get-AzureRmNetworkSecurityGroup) {
        foreach ($networkwatcher in Get-AzurermNetworkWatcher  -ResourceGroupName NetworkWatcherRg) {
            if ($nsg.Location -eq $networkwatcher.Location) {
                Write-Host $networkwatcher.Name, $nsg.Name
                Get-AzureRmNetworkWatcherFlowLogStatus -NetworkWatcher $networkwatcher -TargetResourceId $nsg.Id
            }
        }
    }
}