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
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: network
  name: 'infra'
  properties: {
    addressPrefix: subnetAddressPrefix
  }
}

output id string = network.id
output name string = network.name

output subnetId string = subnet.id
output subnetName string = subnet.name
