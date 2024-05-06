param name string
param location string
param tags object

@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
param storageSku string = 'Standard_LRS'

@description('IDs of the subnets that should be allowed to communicate with the storage account')
param allowedSubnets string[] = []

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: storageSku
  }
  properties: {
    largeFileSharesState: 'Enabled'
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: null
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      virtualNetworkRules: [
        for allowedSubnetId in allowedSubnets: {
          id: allowedSubnetId
          action: 'Allow'
        }
      ]
    }
  }
}

output id string = storageAccount.id
output name string = storageAccount.name
