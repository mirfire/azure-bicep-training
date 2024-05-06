import { ContainerApp } from '../../types.bicep'

param container ContainerApp
param storageAccountName string
@description('Name of the Managed Environment hosting the containers')
param managedEnvironmentName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource managedEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: managedEnvironmentName
}

resource services 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
}

resource fileShares 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = [
  for (volumeMount, index) in container.volumeMounts: if (!empty(container.volumeMounts)) {
    name: '${container.name}${volumeMount.volumeName}share'
    parent: services
  }
]

var storageAccountKey = storageAccount.listKeys().keys[0].value

resource volumeMountsStorages 'Microsoft.App/managedEnvironments/storages@2023-05-01' = [
  for (volumeMount, index) in container.volumeMounts: if (!empty(container.volumeMounts)) {
    name: '${volumeMount.volumeName}storage'
    parent: managedEnvironment
    properties: {
      azureFile: {
        accessMode: 'ReadWrite'
        accountKey: storageAccountKey
        accountName: storageAccountName
        shareName: '${container.name}${volumeMount.volumeName}share'
      }
    }
  }
]
