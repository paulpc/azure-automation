foreach ($subby in Get-AzureRmSubscription ) {
    Write-Host "processing: " $subby.id $subby.Name
    Select-AzureRmSubscription $subby
    foreach ($store in Get-AzureRmStorageAccount -ResourceGroupName NetworkWatcherRG) {
        #$store
        if ($store.StorageAccountName.startswith("$($subby.id.split("-")[0])")) {
            Write-Host "[+] good one: " $store.StorageAccountName
        } else {
            Write-Host "[-] fix mee: " $store.StorageAccountName

        }
    }
}