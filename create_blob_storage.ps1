# getting tags ready
$tags = @{}
$tags_ojb = get-content tags.json | ConvertFrom-Json 
$tags_ojb.psobject.properties | foreach { $tags[$_.Name] = $_.Value }
$tags["Build Date"]=get-date -UFormat "%m/%d/%Y"
# Iterating through things
foreach ($subby in Get-AzureRmSubscription ) {
    Write-Host "processing: " $subby.id $subby.Name
    Select-AzureRmSubscription $subby
    foreach ($location in Get-AzureRmLocation) {
        New-AzureRmStorageAccount -name "$($subby.id.split("-")[0])$($location.Location)" -Kind BlobStorage -Location $($location.Location) -SkuName Standard_LRS -ResourceGroupName NetworkWatcherRG -EnableHttpsTrafficOnly $true -AccessTier Hot -Tag $tags
    }
}