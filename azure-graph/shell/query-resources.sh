#
# Find all VM's and list them with type, name, imageReference and subscription name
#
# {
#  "count": [COUNT],
#  "data": [
#    {
#      "SubName": "[SUBSCRIPTION_NAME]",
#      "name": "[VM_NAME]",
#      "properties_storageProfile_imageReference": {
#        "exactVersion": "[IMAGE_VERSION]",
#        "id": "/subscriptions/[SUBSCRIPTION_ID]/resourceGroups/[RESOURCEGROUP_NAME]/providers/Microsoft.Compute/galleries/[GALLERY_NAME]/images/[IMAGE_DEFINITION_NAME]/version/[IMAGE_VERSION]",
#        "resourceGroup": "[RESOURCEGROUP_NAME]"
#      },
#      "type": "microsoft.compute/virtualmachines"
#    },
# }
#
az graph query -q \
	"Resources | \
	join kind=leftouter \
	  (ResourceContainers | \
		where type=='microsoft.resources/subscriptions' | \
		project SubName=name, subscriptionId) on subscriptionId | \
	where type =~ 'Microsoft.Compute/virtualMachines' | \
	project type, name, SubName, properties.storageProfile.imageReference"

# -----------------------------------------------------------------------------
#
# Find all VMSS's and list them with type, name, imageReference and subscription name
#
# Output:
#
# {
#  "count": [COUNT],
#  "data": [
#    {
#      "SubName": "[SUBSCRIPTION_NAME]",
#      "name": "[VMSS_NAME]",
#      "properties_virtualMachineProfile_storageProfile_imageReference": {
#        "id": "/subscriptions/[SUBSCRIPTION_ID]/resourceGroups/[RESOURCEGROUP_NAME]/providers/Microsoft.Compute/galleries/[GALLERY_NAME]/images/[IMAGE_DEFINITION_NAME]/version/[IMAGE_VERSION]",
#        "resourceGroup": "[RESOURCEGROUP_NAME]"
#      },
#      "type": "microsoft.compute/virtualmachinescalesets"
#    }, ...
# }
#
az graph query -q \
	"Resources | \
	join kind=leftouter \
		(ResourceContainers | \
		where type=='microsoft.resources/subscriptions' | \
		project SubName=name, subscriptionId) on subscriptionId | \
	where type =~ 'Microsoft.Compute/virtualMachineScaleSets' | \
	project type, name, SubName, properties.virtualMachineProfile.storageProfile.imageReference"
