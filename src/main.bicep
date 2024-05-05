targetScope = 'subscription'

@description('Name of the app')
param appName string

@description('Azure location where the infrastructure shall be deployed')
param location string

@allowed(['prod', 'dev'])
param env string

param userTags object = {}

param containerImage string
param vnetAddressPrefix array = [
  '10.0.0.0/16'
]
param subnetAddressPrefix string = '10.0.1.0/24'

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
    vnetAddressPrefix: vnetAddressPrefix
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
// TODO: Loop over needed containers maybe?
module container 'modules/container/main.bicep' = {
  name: '${appName}-front-${env}-ca'
  scope: resourceGroup
  params: {
    name: '${appName}-front-${env}-ca'
    location: location
    tags: tags
    environmentID: containerAppEnvironment.outputs.id
    containerImage: 'ghcr.io/mirfire/dotnet-hello-world:1.0.0'
  }
}
