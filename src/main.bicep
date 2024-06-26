targetScope = 'subscription'
import { ContainerApp } from 'types.bicep'

@description('Name of the app')
param appName string

@description('Azure location where the infrastructure shall be deployed')
param location string

@allowed(['prod', 'dev'])
param env string

@description('Tags to apply to all resources')
param userTags object = {}

@description('List of VNet address prefixes')
param vnetAddressPrefixes string[] = [
  '10.0.0.0/16'
]
@description('Subnet address prefix, must be a valid CIDR block of /23 or bigger')
// https://learn.microsoft.com/en-us/azure/reliability/reliability-azure-container-apps?tabs=azure-cli#enable-zone-redundancy-with-the-azure-cli
param subnetAddressPrefix string = '10.0.0.0/23'

@description('List of containers to deploy')
param containers ContainerApp[]

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
// So far, it is pretty basic and does not store logs
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

// Under this, deployment for an app
module teamApp 'modules/app/main.bicep' = {
  scope: resourceGroup
  name: 'team-app'
  params: {
    location: location
    tags: tags
    appName: appName
    containers: containers
    env: env
    managedEnvironmentName: containerAppEnvironment.name
  }
}
