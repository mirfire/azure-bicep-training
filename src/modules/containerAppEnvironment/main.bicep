param location string
param name string
param tags object

@description('Subnet to dedicate to the container app environment')
param subnetId string

// Most basic of all container environments. No logs. No file share, nothing.
resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    zoneRedundant: true
    vnetConfiguration: {
      internal: false
      infrastructureSubnetId: subnetId
    }
    peerAuthentication: {
      mtls: {
        enabled: false
      }
    }
  }
}

output id string = containerAppEnvironment.id
output name string = containerAppEnvironment.name
