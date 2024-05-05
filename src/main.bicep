targetScope = 'subscription'

@description('Name of the app')
param appName string

@description('Azure location where the infrastructure shall be deployed')
param location string

@allowed(['prod', 'dev'])
param env string

param userTags object = {}

var defaultTags = { appName: appName, env: appName, buildTool: 'bicep' }
var tags = union(userTags, defaultTags)

// Keeping the resource group in the root file and not in a sub module
// Bicep and other resources need the direct reference to function correctly
resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: '${appName}-${env}-rg'
  location: location
  tags: tags
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
  }
}
