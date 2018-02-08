# getting tags ready
$tags = @{}
$tags_ojb = get-content tags.json | ConvertFrom-Json 
$tags_ojb.psobject.properties | foreach { $tags[$_.Name] = $_.Value }
$tags["Build Date"]=get-date -UFormat "%m/%d/%Y"
# Iterating through things
foreach ($subby in Get-AzureRmSubscription ) {
    Write-Host "processing: " $subby.id $subby.Name
    Select-AzureRmSubscription -Subscription $subby.id
    foreach ($nsg in Get-AzureRmNetworkSecurityGroup) {
        # creating the blobs where not already there
        $found=$false
        foreach ($store in Get-AzureRmStorageAccount -ResourceGroupName NetworkWatcherRG) {
            # looking for blobs in the NetworkWatcherRG group
            if ($store.Location -eq $nsg.Location) {
                # that match the location of the NSG
                $found=$true
            }
        }
        # if the blobs don't exist, go ahead and make them
        if ( -NOT ($found) ) {
            Write-Host "Need to create storage $($subby.id.split("-")[0])$($nsg.Location) for $($nsg.Name) in $($nsg.Location)"
            New-AzureRmStorageAccount -name "$($subby.id.split("-")[0])$($nsg.Location)" -Kind BlobStorage -Location $($nsg.Location) -SkuName Standard_LRS -ResourceGroupName NetworkWatcherRG -EnableHttpsTrafficOnly $true -AccessTier Hot -Tag $tags
        }

        foreach ($networkwatcher in Get-AzurermNetworkWatcher  -ResourceGroupName NetworkWatcherRg) {
            if ($nsg.Location -eq $networkwatcher.Location) {
                $flstatus = Get-AzureRmNetworkWatcherFlowLogStatus -NetworkWatcher $networkwatcher -TargetResourceId $nsg.Id
                Write-Host $networkwatcher.Name, $nsg.Name, $flstatus.Enabled
                if (-NOT ($flstatus.Enabled)) {
                    Write-Host "you should enable logging for $($nsg.Name)"
                }
            }
        }
        

    }
}