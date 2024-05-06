import { ContainerApp } from '../../types.bicep'

@description('The name of the application')
param appName string

@description('Name of the Managed Environment hosting the containers')
param managedEnvironmentName string

@description('Environment of the app')
param env string

param containers ContainerApp[]

param location string

param tags object

resource managedEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: managedEnvironmentName
}

var appStorageName = substring('${appName}${env}sa${uniqueString(resourceGroup().id)}', 0, 24)
var subnetID = managedEnvironment.properties.vnetConfiguration.infrastructureSubnetId

module teamStorageAccount '../storageaccount/main.bicep' = {
  name: appStorageName
  params: {
    allowedSubnets: [
      subnetID
    ]
    location: location
    name: appStorageName
    tags: tags
  }
}

module volumeMountShares '../volumeMountShares/main.bicep' = [
  for container in containers: {
    name: '${container.name}shares'
    params: {
      container: container
      storageAccountName: appStorageName
      managedEnvironmentName: managedEnvironment.name
    }
    dependsOn: [
      teamStorageAccount
    ]
  }
]

module containerApps '../container/main.bicep' = [
  for container in containers: {
    name: '${container.name}-${env}'
    params: {
      name: '${container.name}-${env}'
      location: location
      tags: tags
      container: container
      environmentID: managedEnvironment.id
    }
    dependsOn: [
      volumeMountShares
    ]
  }
]
