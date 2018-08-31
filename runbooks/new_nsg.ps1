<#
.SYNOPSIS 
    This sample Automation runbook integrates with Azure event grid subscriptions to get notified when a 
    write command is performed against an Azure VM.
    The runbook adds a cost tag to the VM if it doesn't exist. It also sends an optional notification 
    to a Microsoft Teams channel indicating that a new VM has been created and that it is set up for 
    automatic shutdown / start up tags.
    
.DESCRIPTION
    This sample Automation runbook integrates with Azure event grid subscriptions to get notified when a 
    write command is performed against an Azure VM.
    The runbook adds a cost tag to the VM if it doesn't exist. It also sends an optional notification 
    to a Microsoft Teams channel indicating that a new VM has been created and that it is set up for 
    automatic shutdown / start up tags.
    A RunAs account in the Automation account is required for this runbook.

.PARAMETER WebhookData
    Optional. The information about the write event that is sent to this runbook from Azure Event grid.
  
.PARAMETER ChannelURL
    Optional. The Microsoft Teams Channel webhook URL that information will get sent.

.NOTES
    AUTHOR: Paul PC
    LASTEDIT: March of 2018 
#>
 
Param(
    [parameter (Mandatory=$false)]
    [object] $WebhookData,

    [parameter (Mandatory=$false)]
    $ChannelURL
)

$RequestBody = $WebhookData.RequestBody | ConvertFrom-Json
$Data = $RequestBody.data

if($Data.operationName -match "MICROSOFT.NETWORK/NETWORKSECURITYGROUPS/WRITE")
{
    # Authenticate to Azure
    $ServicePrincipalConnection = Get-AutomationConnection -Name "AzureRunAsConnection"
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $ServicePrincipalConnection.TenantId `
        -ApplicationId $ServicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $ServicePrincipalConnection.CertificateThumbprint | Write-Verbose
    
    # selecting the apropriate subscription
    $Data.resourceUri | Write-Verbose
    $subby = $Data.subscriptionId

    $subby | Write-Verbose                                                                                                                                                         
    #Set-AzureRMContext  -SubscriptionId $subby
    $rg = ($Data.resourceUri -split "/")[4]                                                                                                                                                                     
    $nsg_name = ($Data.resourceUri -split "/")[8] 
    # Set subscription to work against
    Set-AzureRmContext -SubscriptionId $subby | Write-Verbose
    $perp = $data.claims.name
    $nsg = Get-AzureRmNetworkSecurityGroup  -ResourceGroupName $rg -Name $nsg_name

    # If we're able to get details about the NSG, let's do something about it. Otherwise just complain about it.
    if ($nsg) {
        # let's look at the rules:
        $jit_protection=@()
        $rule_mesage=""
        foreach ($securityRule in $nsg.SecurityRules) {
            if ($securityRule.Name.startsWith("SecurityCenter-JITRule") -And $securityRule.Access -eq "Deny"){
                $jit_protection+=$securityRule.DestinationPortRange
            } elseif ($securityRule.Name.startsWith("default-allow") ) {
                foreach ($port in $securityRule.DestinationPortRange) {
                    if ( ! ($port -in $jit_protection) -And "*" -in $securityRule.SourceAddressPrefix) {
                        $rule_mesage+=("found insecure shit - " + $securityRule.Name + " - " + $nsg.Name + "; ")
                    } 
                }
            }
        }
        foreach ($networkwatcher in Get-AzurermNetworkWatcher  -ResourceGroupName NetworkWatcherRg) {
            if ($nsg.Location -eq $networkwatcher.Location) {
                $fl_status = Get-AzureRmNetworkWatcherFlowLogStatus -NetworkWatcher $networkwatcher -TargetResourceId $nsg.Id
                if ( ! ($fl_status.Enabled)) {

                    # this is where we enable the logging
                    $logging = "not logging"
                    #first of all getting the blob account
                    $found=$false
                    $blob_name_start=($subby -split "-")[0]

                    foreach ($store in Get-AzureRmStorageAccount -ResourceGroupName NetworkWatcherRG) {
                        # looking for blobs in the NetworkWatcherRG group and making sure they are the right odd-named-ones
                        if ($store.Location -eq $nsg.Location -And $store.storageaccountname.StartsWith($blob_name_start)) {
                            # that match the location of the NSG
                            #  -And $store.name.StartsWtih($blob_name_start)
                            $found=$store
                        }
                    }

                    # if we found one, we can set it
                    if ($found) {
                        Set-AzureRmNetworkWatcherConfigFlowLog -NetworkWatcher $networkwatcher -TargetResourceId $nsg.Id -EnableFlowLog $true -StorageAccountId $found.Id
                        $logging = "logging to $($found.Id)"
                    }

                    if (!([string]::IsNullOrEmpty($ChannelURL)))
                        {
                            $TargetURL = "https://portal.azure.com/#resource" + $Data.resourceUri + "/overview"   
                            
                            $Body = ConvertTo-Json -Depth 4 @{
                            title = 'NSG Creation notification' 
                            text = 'NSG was created, '+ $logging + ' by ' + $perp
                            sections = @(
                                @{
                                activityTitle = 'Azure NSG'
                                activitySubtitle = 'NSG ' + $nsg.Name + ' has been created.'
                                activityText = 'NSG ' + $subby + ' and resource group ' + $nsg.ResourceGroupName + "; " + $rule_mesage
                                activityImage = 'https://azure.microsoft.com/svghandler/automation/'
                                }
                            )
                            potentialAction = @(@{
                                '@context' = 'http://schema.org'
                                '@type' = 'ViewAction'
                                name = 'Click here to manage the NSG'
                                target = @($TargetURL)
                                })
                            }
                            
                            # call Teams webhook
                            Invoke-RestMethod -Method "Post" -Uri $ChannelURL -Body $Body | Write-Verbose
                        }
                    }
                }
            }
    } else {
        if (!([string]::IsNullOrEmpty($ChannelURL)))
        {
            $TargetURL = "https://portal.azure.com/#resource" + $Data.resourceUri + "/overview"   
            
            $Body = ConvertTo-Json -Depth 4 @{
            title = 'NSG Creation notification' 
            text = 'NSG ' + $nsg_name + ' was created, but I am unable to get many details on it'
            sections = @(
                @{
                activityTitle = 'Azure NSG'
                activitySubtitle = 'NSG has been created: ' + $Data.resourceUri + ' by ' + $perp
                activityText = 'NSG has been created in the following subscription ' + $subby + ' but I cannot do anything about it'
                activityImage = 'https://azure.microsoft.com/svghandler/automation/'
                }
            )
            potentialAction = @(@{
                '@context' = 'http://schema.org'
                '@type' = 'ViewAction'
                name = 'Click here to manage the NSG'
                target = @($TargetURL)
                })
            }
            
            # call Teams webhook
            Invoke-RestMethod -Method "Post" -Uri $ChannelURL -Body $Body | Write-Verbose
        }
    }
    }