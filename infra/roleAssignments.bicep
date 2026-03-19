@description('Name of the existing Cognitive Services account')
param cognitiveServicesAccountName string

@description('Principal ID of the managed identity to assign roles to')
param principalId string

// Well-known role definition IDs
var roleIds = [
  '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd' // Cognitive Services OpenAI User
  '64702f94-c441-49e6-a78b-ef80e0188fee' // Azure AI Developer
  'a97b65f3-24c7-4388-baec-2e87135dc908' // Cognitive Services User
]

resource cognitiveAccount 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = {
  name: cognitiveServicesAccountName
}

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for roleId in roleIds: {
    name: guid(cognitiveAccount.id, principalId, roleId)
    scope: cognitiveAccount
    properties: {
      principalId: principalId
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId)
      principalType: 'ServicePrincipal'
    }
  }
]
