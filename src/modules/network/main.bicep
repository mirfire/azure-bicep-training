@description('The location where the virtual network will be created.')
param location string
@description('The name of the virtual network.')
param name string
@description('The tags to associate with the virtual network.')
param tags object

@description('The address prefixes for the virtual network.')
param vnetAddressPrefix array
@description('The address prefix for the subnet.')
param subnetAddressPrefix string

resource network 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefix
    }
    subnets: [
      {
        name: 'infra'
        properties: {
          addressPrefix: subnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

output id string = network.id
output name string = network.name

output subnetId string = network.properties.subnets[0].id
output subnetName string = network.properties.subnets[0].name
