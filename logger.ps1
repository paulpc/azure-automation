foreach ($subscription in get-azurermsubscription ) {
echo $subscription
Set-AzureRmContext -SubscriptionId "$subscription"
get-azurermlogprofile -n default
}
