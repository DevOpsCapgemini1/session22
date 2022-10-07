param appServicePlanName string
param appServiceName string
param location string = resourceGroup().location
param skuTier string
param nodesInWebFarm int
param dockerImage string

resource appServicePlan_resource 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  sku: {
    name: skuTier
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
    }
  }
}
