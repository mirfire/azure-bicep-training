param location string
param name string
param tags object

// Most basic of all container environments. No logs. No file share, nothing.
resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2023-11-02-preview' = {
  name: name
  location: location
  tags: tags
  properties: {}
}

output id string = containerAppEnvironment.id
output name string = containerAppEnvironment.name
