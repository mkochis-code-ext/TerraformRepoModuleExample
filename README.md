# TerraformRepoModuleExample - Terraform Infrastructure

> **Disclaimer:** This repository is provided purely as a demonstration of these workflows. You are free to use, modify, and adapt the code as you see fit; however, it is offered as-is with no warranty or support of any kind. Use it at your own risk. This is not production-ready code — it should be reviewed, understood, and rewritten to suit your own environment before any real-world use.

This Terraform configuration uses a two-layer modular architecture to deploy an Azure infrastructure consisting of a **Resource Group** and an **App Service**, sourcing reusable modules from the [TerraformModuleExample](https://github.com/mkochis-code-ext/TerraformModuleExample) repository at version `v1.0.0`.

## 📁 Folder Structure

```
terraform/
├── environments/
│   └── dev/
│       ├── main.tf                    # Environment-specific configuration & provider setup
│       ├── variables.tf               # Environment variables
│       ├── outputs.tf                 # Environment outputs
│       └── terraform.tfvars.example   # Example variable values
└── project/
    ├── main.tf                        # Project-level orchestration (calls remote modules)
    ├── variables.tf                   # Project variables
    └── outputs.tf                     # Project outputs
```

## 🏗️ Architecture Overview

### Two-Layer Design

1. **Environments Layer** (`environments/dev/`)
   - Terraform and provider version constraints
   - Generates random suffix for resource uniqueness
   - Sets environment-specific configuration
   - Calls the project module

2. **Project Layer** (`project/`)
   - Orchestrates all infrastructure components
   - Builds resource names following naming conventions
   - Sources reusable modules from the external module repository at `v1.0.0`
   - Manages dependencies between resources

### Remote Modules (v1.0.0)

Modules are sourced from [mkochis-code-ext/TerraformModuleExample](https://github.com/mkochis-code-ext/TerraformModuleExample) using the git source format:

```hcl
source = "git::https://github.com/mkochis-code-ext/TerraformModuleExample.git//modules/<module-name>?ref=v1.0.0"
```

### Deployed Resources

- **Resource Group**: Container for all resources (`rg-<workload>-<env>-<suffix>`)
- **App Service Plan + Web App**: Hosts the application (`app-<workload>-<env>-<suffix>`)

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Active Azure subscription with appropriate permissions
- Git (required for Terraform to clone remote modules)

### Deployment Steps

1. **Authenticate with Azure**

```bash
az login
az account set --subscription "<your-subscription-id>"
```

2. **Navigate to Environment Directory**

```bash
cd terraform/environments/dev
```

3. **Configure Variables**

Copy and customize the tfvars file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

4. **Initialize Terraform**

```bash
terraform init
```

5. **Review the Deployment Plan**

```bash
terraform plan
```

6. **Deploy Infrastructure**

```bash
terraform apply
```

Type `yes` when prompted.

## ⚙️ Configuration

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `environment_prefix` | Environment name | `dev` |
| `workload` | Workload identifier | `terraform-sample` |
| `location` | Azure region | `eastus` |
| `app_service_os_type` | OS type for App Service Plan (`Linux` or `Windows`) | `Linux` |
| `app_service_sku_name` | SKU for App Service Plan (e.g. `F1`, `B1`, `S1`) | `B1` |

### Resource Naming Convention

Resources follow: `<type>-<workload>-<environment>-<suffix>`

Examples:
- Resource Group: `rg-terraform-sample-dev-a1b`
- App Service: `app-terraform-sample-dev-a1b`

## 📤 Outputs

After deployment, these outputs are available:

| Output | Description |
|--------|-------------|
| `resource_group_name` | Resource group name |
| `resource_group_id` | Resource group ID |
| `app_service_name` | App Service name |
| `app_service_id` | App Service ID |
| `app_service_default_hostname` | Default hostname of the App Service |

View all outputs:

```bash
terraform output
```

## 🔄 CI/CD Pipeline Setup

Both the GitHub Actions workflow (`.github/workflows/main.yml`) and the Azure DevOps pipeline (`.ado/pipelines/main.yml`) share the same general flow:

- **CI**: Runs `fmt`, `init`, `validate`, and `plan` on pull requests targeting `main`, then posts results as a PR comment
- **CD**: Triggered manually on `main`; runs `plan`, waits for approval, then runs `apply`

### Azure Prerequisites (Required for Both)

Complete these steps once regardless of which CI/CD platform you use.

#### 1. Create a Service Principal

```bash
az ad sp create-for-rbac \
  --name "sp-terraform-cicd" \
  --role Contributor \
  --scopes /subscriptions/<your-subscription-id> \
  --sdk-auth
```

Save the output — you will need `clientId`, `clientSecret`, `subscriptionId`, and `tenantId`.

#### 2. Create a Storage Account for Terraform State

```bash
# Create a resource group for state storage
az group create \
  --name rg-terraform-state \
  --location eastus

# Create the storage account (name must be globally unique)
az storage account create \
  --name <your-storage-account-name> \
  --resource-group rg-terraform-state \
  --sku Standard_LRS \
  --allow-blob-public-access false

# Create the state container
az storage container create \
  --name tfstate \
  --account-name <your-storage-account-name>
```

#### 3. Grant the Service Principal Access to the State Storage Account

```bash
SP_OBJECT_ID=$(az ad sp show --id <clientId> --query id -o tsv)

az role assignment create \
  --assignee-object-id $SP_OBJECT_ID \
  --role "Storage Blob Data Contributor" \
  --scope /subscriptions/<subscription-id>/resourceGroups/rg-terraform-state/providers/Microsoft.Storage/storageAccounts/<your-storage-account-name>
```

#### Required Secret Values

| Secret Name | Description |
|---|---|
| `ARM_CLIENT_ID` | Service principal client ID |
| `ARM_CLIENT_SECRET` | Service principal client secret |
| `ARM_SUBSCRIPTION_ID` | Azure subscription ID |
| `ARM_TENANT_ID` | Azure tenant ID |
| `TF_STATE_STORAGE_ACCOUNT` | Storage account name for Terraform state |
| `TF_STATE_RESOURCE_GROUP` | Resource group containing the state storage account |
| `DEV_LOCATION` | Azure region for the dev environment (e.g. `eastus`) |

---

### GitHub Actions Setup

#### 1. Add Repository Secrets

In your GitHub repository, go to **Settings → Secrets and variables → Actions → New repository secret** and add each value from the [Required Secret Values](#required-secret-values) table above.

#### 2. Verify the Workflow File

Ensure `.github/workflows/main.yml` exists in the repository. The workflow will activate automatically on the next pull request or push to `main`.

#### 3. Pipeline Behavior

| Trigger | Behavior |
|---|---|
| Pull request targeting `main` | Runs CI: fmt check, init, validate, plan; posts results as a PR comment |
| Manual (`workflow_dispatch`) with stage `Dev` on `main` | Runs CD: init, plan, apply to dev environment |

> The `dev` GitHub Environment can be configured under **Settings → Environments** to add required reviewers or wait timers before the deploy job runs.

---

### Azure DevOps Setup

#### 1. Install the Terraform Extension

Install the **Terraform** extension from the marketplace into your ADO organization. This provides the `TerraformInstaller@1` task used in the pipeline.

[ms-devlabs.custom-terraform-tasks](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks)

#### 2. Create a Variable Group

In **Pipelines → Library → + Variable group**, create a group named `terraform-secrets` and add each value from the [Required Secret Values](#required-secret-values) table above. Mark sensitive values as secret.

#### 3. Create the Dev Environment

In **Pipelines → Environments → New environment**, create an environment named `dev`. To enforce manual approval before `apply`:

1. Open the `dev` environment
2. Select **Approvals and checks → +**
3. Add an **Approvals** check and specify the required approvers

> The `ManualValidation` task in the pipeline also adds an inline approval gate before the apply job runs, acting as a second confirmation prompt.

#### 4. Enable the Pipeline to Post PR Comments

The CI stage uses `System.AccessToken` to call the ADO REST API and post plan output as a PR comment. To enable this:

1. Edit the pipeline
2. Select **...** (more options) → **Triggers**
3. Under **YAML** → **Get sources**, check **Allow scripts to access the OAuth token**

Alternatively, add the following to the pipeline job:

```yaml
- job: TerraformPlan
  ...
  env:
    SYSTEM_ACCESSTOKEN: $(System.AccessToken)
```

This is already included in the pipeline definition.

#### 5. Create the Pipeline

1. In **Pipelines → New pipeline**, select your repository source
2. Choose **Existing Azure Pipelines YAML file**
3. Set the path to `.ado/pipelines/main.yml`
4. Link the `terraform-secrets` variable group under **Variables → Variable groups**
5. Save and run

#### 6. Pipeline Behavior

| Trigger | Behavior |
|---|---|
| Pull request targeting `main` | Runs CI stage: fmt check, init, validate, plan; posts results as a PR thread comment |
| Manual run with stage `Dev` on `main` | Runs CD stage: plan → manual approval → apply to dev environment |

---

## 🧹 Cleanup

To destroy all resources:

```bash
cd terraform/environments/dev
terraform destroy
```

Type `yes` to confirm. This will remove all resources in the resource group.

## 🐛 Troubleshooting

### Common Issues

**Terraform init fails when cloning modules**
- Ensure Git is installed on the machine running Terraform
- Verify network access to `https://github.com`
- Check that the `v1.0.0` tag exists in the [TerraformModuleExample](https://github.com/mkochis-code-ext/TerraformModuleExample) repository

**Terraform init fails (general)**
- Verify Terraform version >= 1.0
- Check internet connectivity
- Clear `.terraform` directory and retry

## 📚 Additional Resources

- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [TerraformModuleExample Repository](https://github.com/mkochis-code-ext/TerraformModuleExample)
- [Terraform Module Sources - Git](https://developer.hashicorp.com/terraform/language/modules/sources#github)
