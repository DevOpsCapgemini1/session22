param appServicePlanName string
param appServiceName string
param location string = resourceGroup().location
param pricingTier string
param nodesInWebFarm int
param dockerImage string
@secure()
param administratorLogin string
@secure()
param administratorLoginPassword string
resource appServicePlan_resource 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  sku: {
    name: pricingTier
  }
  tags: {
    displayName: appServicePlanName
  }
  properties: {
    targetWorkerCount: nodesInWebFarm
    reserved: true
  }
}

resource appService_resource 'Microsoft.Web/sites@2020-12-01' = {
  name: appServiceName
  location: location
  kind: 'app,linux,container'
  tags: {
    'hidden-related:${resourceGroup().id}/providers/Microsoft.Web/serverfarms/${appServicePlanName}': 'Resource'
    displayName: appServiceName
  }
  properties: {
    httpsOnly: false
    serverFarmId: appServicePlan_resource.id
    siteConfig: {
      numberOfWorkers: nodesInWebFarm
      linuxFxVersion: 'DOCKER|${dockerImage}'
      appSettings: [
        {
          name: 'SqlDatabase'
          value: 'Server=tcp:mbidzins-sql-server.database.windows.net,1433;Initial Catalog=mbidzins-sql-db;Persist Security Info=False;User ID=${administratorLogin};Password=${administratorLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
        }
      ]
    }
  }
}
