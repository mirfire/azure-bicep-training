targetScope = 'subscription'

param location string
param name string
param tags object

resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: name
  location: location
  tags: tags
}
