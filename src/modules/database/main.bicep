param name string
param location string
param tags object

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
  }
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
}
