@description('Location for all resources')
param location string

@description('Tags to apply to resources')
param tags object

@description('Unique token for generating resource names')
param resourceToken string

@description('Azure AI Foundry project endpoint')
param projectEndpoint string

@description('Agent name in the Foundry project')
param agentName string

@description('Azure tenant ID for cross-tenant auth')
param tenantId string

var appServicePlanName = 'plan-${resourceToken}'
var appServiceName = 'app-${resourceToken}'

resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: 'B1'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource webApp 'Microsoft.Web/sites@2024-04-01' = {
  name: appServiceName
  location: location
  tags: union(tags, { 'azd-service-name': 'web' })
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.12'
      appCommandLine: 'gunicorn --bind=0.0.0.0 --timeout 120 app:app'
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        { name: 'PROJECT_ENDPOINT', value: projectEndpoint }
        { name: 'AGENT_NAME', value: agentName }
        { name: 'AZURE_TENANT_ID', value: tenantId }
        { name: 'FLASK_SECRET_KEY', value: uniqueString(resourceGroup().id, appServiceName) }
        { name: 'SCM_DO_BUILD_DURING_DEPLOYMENT', value: 'true' }
      ]
    }
  }
}

output uri string = 'https://${webApp.properties.defaultHostName}'
output name string = webApp.name
output identityPrincipalId string = webApp.identity.principalId
