foreach ($subby in Get-AzureRmSubscription ) {
    Write-Host "processing: " $subby.id $subby.Name
    Select-AzureRmSubscription $subby
    foreach ($store in Get-AzureRmStorageAccount -ResourceGroupName NetworkWatcherRG) {
        $store
        if (-not ($store.Name -eq "$($subby.id.split("-")[0])$($store.Location)")) {
            Write-Host "faulty creation. Fix me plz"
        }
    }
}