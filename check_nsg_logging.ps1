foreach ($subby in Get-AzureRmSubscription ) {
    Select-AzureRmSubscription -Subscription $subby.id
    foreach ($nsg in Get-AzureRmNetworkSecurityGroup) {
        foreach ($networkwatcher in Get-AzurermNetworkWatcher  -ResourceGroupName NetworkWatcherRg) {
            if ($nsg.Location -eq $networkwatcher.Location) {
                Write-Host $networkwatcher.Name, $nsg.Name, $subby.SubscriptionName
                $flstatus = Get-AzureRmNetworkWatcherFlowLogStatus -NetworkWatcher $networkwatcher -TargetResourceId $nsg.Id
                if (-NOT ($flstatus.Enabled)) {
                    foreach ($store in Get-AzureRmStorageAccount -ResourceGroupName NetworkWatcherRG) {
                        $found=$fasle
                        if ($store.Location -eq $nsg.Location) {
                            Write-Host "you should enable logging for $nsg.Name"
                            $found=$true
                        }
                    }
                    if ( -NOT $found) {
                        Write-Host "Need to create storage "$($subby.id.split("-")[0])$($nsg.Location)" for  $($nsg.Name) in $($nsg.Location)"
                        #New-AzureRmStorageAccount -name "$($subby.id.split("-")[0])$($nsg.Location)"
                    }
                }
            }
        }
    }
}