param managedEnvironmentName string
param env string
param location string
param tags object
param fileShareName string
param subnetID string

resource managedEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: managedEnvironmentName
}

var teamStorageAccountName = 'teamstorage${uniqueString(resourceGroup().id)}'

module teamStorageAccount '../storageaccount/main.bicep' = {
  name: teamStorageAccountName
  params: {
    allowedSubnets: [
      subnetID
    ]
    location: location
    name: teamStorageAccountName
    tags: tags
  }
}

resource frontendFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  name: '${teamStorageAccount.name}/default/${fileShareName}'
  dependsOn: [
    teamStorageAccount
  ]
}

var teamStorageAccountKey = listKeys(
  resourceId('Microsoft.Storage/storageAccounts', teamStorageAccount.name),
  '2023-01-01'
).keys[0].value

resource frontendStorage 'Microsoft.App/managedEnvironments/storages@2023-05-01' = {
  #disable-next-line use-parent-property // can't use parent property as we skip it with frontendFileShare
  name: '${managedEnvironment.name}/frontendstorage'
  properties: {
    azureFile: {
      accountName: teamStorageAccount.name
      shareName: frontendFileShare.name
      accountKey: teamStorageAccountKey
      accessMode: 'ReadWrite'
    }
  }
  dependsOn: [
    teamStorageAccount
    managedEnvironment
  ]
}

resource frontend 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'frontend-${env}'
  location: location
  properties: {
    environmentId: managedEnvironment.id
    configuration: {
      ingress: {
        targetPort: 8080
        external: true
      }
      activeRevisionsMode: 'Single'
    }
    template: {
      containers: [
        {
          name: 'dotnet-hello-world'
          image: 'ghcr.io/mirfire/dotnet-hello-world:1.0.0'
          volumeMounts: [
            {
              volumeName: 'frontendvolume'
              mountPath: '/data'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 3 // 3 Availability zones
        maxReplicas: 9 // Arbitrary
      }
      volumes: [
        {
          name: 'frontendvolume'
          storageName: 'frontendstorage'
          storageType: 'AzureFile'
        }
      ]
    }
  }
  dependsOn: [
    frontendStorage
  ]
}
