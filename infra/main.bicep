targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment used to generate resource names')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Azure AI Foundry project endpoint')
param projectEndpoint string

@description('Agent name in the Foundry project')
param agentName string = 'TestWorkflowForWeb'

@description('Azure tenant ID for cross-tenant auth')
param tenantId string

@description('Name of the existing Cognitive Services account for role assignments')
param cognitiveServicesAccountName string

@description('Resource group of the existing Cognitive Services account')
param cognitiveServicesResourceGroup string

var tags = { 'azd-env-name': environmentName }
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module web 'web.bicep' = {
  scope: rg
  params: {
    location: location
    tags: tags
    resourceToken: resourceToken
    projectEndpoint: projectEndpoint
    agentName: agentName
    tenantId: tenantId
  }
}

module roles 'roleAssignments.bicep' = {
  scope: resourceGroup(cognitiveServicesResourceGroup)
  params: {
    cognitiveServicesAccountName: cognitiveServicesAccountName
    principalId: web.outputs.identityPrincipalId
  }
}

output AZURE_LOCATION string = location
output SERVICE_WEB_URI string = web.outputs.uri
