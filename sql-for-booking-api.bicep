param sqlServerName string
param location string = resourceGroup().location
param sqlDbName string
param pricingTier string = 'Standard'
@allowed([
  'Geo'
  'GeoZone'
  'Local'
  'Zone'
])
param dbBackupPolicy string = 'Local'
param firewallRules array = [
  '0.0.0.0'
  '255.255.255.255'
]
@secure()
param administratorLogin string
@secure()
param administratorLoginPassword string
resource sqlServer_resource 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: sqlServerName
  location: location
  tags: {
    displayName: sqlServerName
  }
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
}

resource sqlServerFirewallRules_resource 'Microsoft.Sql/servers/firewallRules@2021-11-01-preview' = {
  parent: sqlServer_resource

  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: first(firewallRules)
    endIpAddress: last(firewallRules)
  }
}

resource sqlDb_resource 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  parent: sqlServer_resource
  name: sqlDbName
  location: location
  tags: {
    displayName: sqlDbName
  }
  sku: {
    name: pricingTier
    tier: pricingTier
  }
  properties: {
    requestedBackupStorageRedundancy: dbBackupPolicy

  }
}
