foreach ($subscription in Get-AzureRmSubscription ) {
    echo $subscription.SubscriptionName
    Select-AzureRmSubscription -Subscription $subscription.id
    foreach ($logpro in Get-AzureRmLogProfile) {
        echo $logpro.ServiceBusRuleId
        
    }
}