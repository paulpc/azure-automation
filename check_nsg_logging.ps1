# getting tags ready
$tags = @{}
$tags_ojb = get-content tags.json | ConvertFrom-Json 
$tags_ojb.psobject.properties | foreach { $tags[$_.Name] = $_.Value }
$tags["Build Date"]=get-date -UFormat "%m/%d/%Y"
# Iterating through things
foreach ($subby in Get-AzureRmSubscription ) {
    Select-AzureRmSubscription -Subscription $subby.id
    foreach ($nsg in Get-AzureRmNetworkSecurityGroup) {
        foreach ($networkwatcher in Get-AzurermNetworkWatcher  -ResourceGroupName NetworkWatcherRg) {
            if ($nsg.Location -eq $networkwatcher.Location) {
                Write-Host $networkwatcher.Name, $nsg.Name, $subby.SubscriptionName
                $flstatus = Get-AzureRmNetworkWatcherFlowLogStatus -NetworkWatcher $networkwatcher -TargetResourceId $nsg.Id
                if (-NOT ($flstatus.Enabled)) {
                    Write-Host "you should enable logging for$($nsg.Name)"
                }
                $found=$false
                foreach ($store in Get-AzureRmStorageAccount -ResourceGroupName NetworkWatcherRG) {
                    if ($store.Location -eq $nsg.Location) {
                        $found=$true
                    }
                }
                if ( -NOT ($found) ) {
                    Write-Host "Need to create storage $($subby.id.split("-")[0])$($nsg.Location) for  $($nsg.Name) in $($nsg.Location)"
                    #New-AzureRmStorageAccount -name "$($subby.id.split("-")[0])$($nsg.Location)" -Kind BlobStorage -Location $($nsg.Location) -SkuName Standard_LRS -ResourceGroupName NetworkWatcherRG -EnableHttpsTrafficOnly $true -AccessTier Hot -Tag $tags
                }
            }
        }
    }
}