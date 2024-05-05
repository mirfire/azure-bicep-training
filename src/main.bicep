targetScope = 'subscription'

@description('Name of the app')
param appName string

@description('Azure location where the infrastructure shall be deployed')
param location string

@allowed(['prod', 'dev'])
param env string

param userTags object = {}

var uid = uniqueString(appName, env, location)

var defaultTags = { appName: appName, env: appName, buildTool: 'bicep' }
var tags = union(userTags, defaultTags)

module resourceGroup 'modules/resourceGroup/main.bicep' = {
  name: '${appName}-${env}-rg'
  params: {
    name: '${appName}-${env}-rg'
    location: location
    tags: tags
  }
}
