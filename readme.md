# Foundry Workflow Chat UI

A Flask web app that provides a chat interface for invoking an Azure AI Foundry workflow agent.

## Prerequisites

- **Azure subscription** with permissions to create App Service resources and assign RBAC roles
- **Azure CLI** (`az`) installed and logged in
- **Azure Developer CLI** (`azd`) installed — [Install guide](https://learn.microsoft.com/azure/developer/azure-dev/install-azd)
- **Python 3.12+** (for local development)
- An **Azure AI Foundry project** with a deployed workflow agent

You'll need the following values from your Foundry project:

| Value | Description | Example |
|---|---|---|
| **Project endpoint** | Full API endpoint of your Foundry project | `https://<resource>.services.ai.azure.com/api/projects/<project>` |
| **Agent name** | Name of the workflow agent to invoke | `TestWorkflowForWeb` |
| **Tenant ID** | Azure AD tenant ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| **Cognitive Services account name** | Name of the Cognitive Services resource backing your Foundry project | `my-foundry-resource` |
| **Cognitive Services resource group** | Resource group containing the Cognitive Services account | `rg-my-foundry` |

## Deploy to Azure

1. Clone the repo and `cd` into it.

2. Initialise an azd environment:
   ```
   azd env new <env-name>
   ```

3. Set the required environment variables:
   ```
   azd env set AZURE_LOCATION <region>
   azd env set PROJECT_ENDPOINT <your-foundry-project-endpoint>
   azd env set AGENT_NAME <your-agent-name>
   azd env set AZURE_TENANT_ID <your-tenant-id>
   azd env set COGNITIVE_SERVICES_ACCOUNT_NAME <your-cognitive-services-account>
   azd env set COGNITIVE_SERVICES_RESOURCE_GROUP <your-cognitive-services-rg>
   ```

4. Provision and deploy:
   ```
   azd up
   ```

This creates:
- A resource group `rg-<env-name>`
- An App Service Plan (B1 Linux) and Web App (Python 3.12) with system-assigned managed identity
- RBAC role assignments (Cognitive Services OpenAI User, Azure AI Developer, Cognitive Services User) on the existing Cognitive Services account

The app URL is printed as `SERVICE_WEB_URI` in the output.

## Run Locally

1. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

2. Create a `.env` file:
   ```
   PROJECT_ENDPOINT=<your-foundry-project-endpoint>
   AGENT_NAME=<your-agent-name>
   AZURE_TENANT_ID=<your-tenant-id>
   ```

3. Run:
   ```
   python app.py
   ```

4. Open http://localhost:5000 in your browser.

Local auth uses `DefaultAzureCredential`, so ensure you're logged in via `az login`.

## Tear Down

```
azd down
```
