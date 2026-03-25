#!/usr/bin/env pwsh
# Assign RBAC roles on the existing Cognitive Services account to the web app's managed identity.
# This runs as a post-provision hook so azd down doesn't try to delete the Foundry resource.

$principalId = (azd env get-value WEB_IDENTITY_PRINCIPAL_ID)
$cogAccount = (azd env get-value COGNITIVE_SERVICES_ACCOUNT_NAME)
$cogRg = (azd env get-value COGNITIVE_SERVICES_RESOURCE_GROUP)
$subId = (azd env get-value AZURE_SUBSCRIPTION_ID)

$scope = "/subscriptions/$subId/resourceGroups/$cogRg/providers/Microsoft.CognitiveServices/accounts/$cogAccount"

$roles = @(
    "Cognitive Services OpenAI User",
    "Azure AI Developer",
    "Cognitive Services User"
)

foreach ($role in $roles) {
    Write-Host "Assigning role '$role' to principal $principalId..."
    az role assignment create `
        --assignee $principalId `
        --role $role `
        --scope $scope `
        --only-show-errors `
        -o none 2>&1 | Out-Null
}

Write-Host "Role assignments complete."
