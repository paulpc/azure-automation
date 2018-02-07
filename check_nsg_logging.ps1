foreach ($subby in Get-AzureRmSubscription ) {
    Select-AzureRmSubscription -Subscription $subby.id
    foreach ($nsg in Get-AzureRmNetworkSecurityGroup) {
        foreach ($networkwatcher in Get-AzurermNetworkWatcher  -ResourceGroupName NetworkWatcherRg) {
            if ($nsg.Location -eq $networkwatcher.Location) {
                Write-Host $networkwatcher.Name, $nsg.Name, $subby.SubscriptionName
                $flstatus = Get-AzureRmNetworkWatcherFlowLogStatus -NetworkWatcher $networkwatcher -TargetResourceId $nsg.Id
                if ($flstatus.Enabled -eq "False") {                    
                            Write-Host "you should enable logging for $($nsg.Name)"
                        }
                    }
                foreach ($store in Get-AzureRmStorageAccount -ResourceGroupName NetworkWatcherRG) {
                    $found=$false
                    if ($store.Location -eq $nsg.Location) {
                        $found=$true
                    }
                    if ( -NOT ($found)) {
                        Write-Host "Need to create storage for $($nsg.Name) in $($nsg.Location)"
                    }
                }
            }
        }
    }
