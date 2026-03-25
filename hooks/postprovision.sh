#!/bin/sh
# Assign RBAC roles on the existing Cognitive Services account to the web app's managed identity.
# This runs as a post-provision hook so azd down doesn't try to delete the Foundry resource.

set -e

principalId=$(azd env get-value WEB_IDENTITY_PRINCIPAL_ID)
cogAccount=$(azd env get-value COGNITIVE_SERVICES_ACCOUNT_NAME)
cogRg=$(azd env get-value COGNITIVE_SERVICES_RESOURCE_GROUP)
subId=$(azd env get-value AZURE_SUBSCRIPTION_ID)

scope="/subscriptions/$subId/resourceGroups/$cogRg/providers/Microsoft.CognitiveServices/accounts/$cogAccount"

for role in "Cognitive Services OpenAI User" "Azure AI Developer" "Cognitive Services User"; do
    echo "Assigning role '$role' to principal $principalId..."
    az role assignment create \
        --assignee "$principalId" \
        --role "$role" \
        --scope "$scope" \
        --only-show-errors \
        -o none 2>/dev/null || true
done

echo "Role assignments complete."
