Param (
  [string] $subscription = "",
  [string] $subscription_security = "",
  [string] $sec_resource_group = "",
  [string] $sec_storage_account_name = ""
)

Set-AzContext –Subscription "$subscription_security"

$storageAccount = Get-AzStorageAccount -ResourceGroupName "$sec_resource_group" -Name "$sec_storage_account_name"

$law = Get-AzOperationalInsightsWorkspace

$workspaceResourceId= $law.ResourceId
$workspaceGUID = $law.CustomerId
$workspaceLocation = $law.Location

Set-AzContext –Subscription "$subscription"
$NW = Get-AzNetworkWatcher -ResourceGroupName NetworkWatcherRg -Name NetworkWatcher_westeurope


$VirtualNetworks =  Get-AzVirtualNetwork
foreach($vnet in $VirtualNetworks){
    $vnet_object = Get-AzVirtualNetwork -Name $vnet.Name

    $subnets = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet_object

    foreach($subnet in $subnets){
        Set-AzNetworkWatcherConfigFlowLog -NetworkWatcher $NW -TargetResourceId $subnet.NetworkSecurityGroup.Id -StorageAccountId $storageAccount.Id -EnableFlowLog $true -FormatType Json -FormatVersion 2 -EnableTrafficAnalytics -WorkspaceResourceId $workspaceResourceId -WorkspaceGUID $workspaceGUID -WorkspaceLocation $workspaceLocation -RetentionInDays 90 -EnableRetention $true -TrafficAnalyticsInterval 10
    }
}
