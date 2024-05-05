targetScope = 'subscription'
import { arrayString, ContainerApp, ContainerApps } from 'types.bicep'

@description('Name of the app')
param appName string

@description('Azure location where the infrastructure shall be deployed')
param location string

@allowed(['prod', 'dev'])
param env string

@description('Tags to apply to all resources')
param userTags object = {}

@description('List of VNet address prefixes')
param vnetAddressPrefixes arrayString = [
  '10.0.0.0/16'
]
@description('Subnet address prefix, must be a valid CIDR block of /23 or bigger')
// https://learn.microsoft.com/en-us/azure/reliability/reliability-azure-container-apps?tabs=azure-cli#enable-zone-redundancy-with-the-azure-cli
param subnetAddressPrefix string = '10.0.0.0/23'

param containers ContainerApps

var defaultTags = { appName: appName, env: appName, buildTool: 'bicep' }
var tags = union(userTags, defaultTags)

// Keeping the resource group in the root file and not in a sub module
// Bicep and other resources need the direct reference to function correctly
resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: '${appName}-${env}-rg'
  location: location
  tags: tags
}

// Deploying a network to contain the environment
// Required for environment to have redundancy over the different availability zones
module network 'modules/network/main.bicep' = {
  name: '${appName}-${env}-nw'
  scope: resourceGroup
  params: {
    name: '${appName}-${env}-nw'
    location: location
    tags: tags
    vnetAddressPrefix: vnetAddressPrefixes
    subnetAddressPrefix: subnetAddressPrefix
  }
}

// Deploying a the environment to run the containers in
// So far, it is extremely basic and does not store logs, nor has any file sharing/mounts
module containerAppEnvironment 'modules/containerAppEnvironment/main.bicep' = {
  name: '${appName}-${env}-caenv'
  scope: resourceGroup
  params: {
    name: '${appName}-${env}-caenv'
    location: location
    tags: tags
    subnetId: network.outputs.subnetId
  }
}

// Deploying just one container so far
module containerApps 'modules/container/main.bicep' = [
  for container in containers: {
    scope: resourceGroup
    name: '${container.name}-${appName}-${env}'
    params: {
      name: '${container.name}-${appName}-${env}'
      tags: tags
      environmentID: containerAppEnvironment.outputs.id
      location: location
      container: container
    }
  }
]
