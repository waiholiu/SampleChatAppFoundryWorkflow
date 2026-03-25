using './main.bicep'

param environmentName = readEnvironmentVariable('AZURE_ENV_NAME', '')
param location = readEnvironmentVariable('AZURE_LOCATION', 'australiaeast')
param projectEndpoint = readEnvironmentVariable('PROJECT_ENDPOINT', 'https://wai-test-project-demo1-resource.services.ai.azure.com/api/projects/wai-test-project-demo1')
param agentName = readEnvironmentVariable('AGENT_NAME', 'TestWorkflowForWeb')
param tenantId = readEnvironmentVariable('AZURE_TENANT_ID', '10fab3c5-d830-4648-973b-8a6fbf7c81d4')
