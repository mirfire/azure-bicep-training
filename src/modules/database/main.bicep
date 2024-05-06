param name string
param location string
param tags object

@description('Subnet to deploy the database into')
param subnetId string

@description('List of database names to create')
param databaseNames string[]

@secure()
param pgsqlAdminUser string

@secure()
param pgsqlAdminPassword string

resource postgreSQLServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    administratorLogin: pgsqlAdminUser
    administratorLoginPassword: pgsqlAdminPassword
    version: '16'
    storage: {
      storageSizeGB: 32
    }
    network: {
      delegatedSubnetResourceId: subnetId
    }
  }
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
}

resource databases 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01' = [
  for database in databaseNames: {
    name: database
    parent: postgreSQLServer
  }
]
