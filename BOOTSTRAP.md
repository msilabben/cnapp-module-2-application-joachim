# Bootstrap guide

This repository assumes one Azure subscription, one GitHub Actions managed identity, and separate GitHub Environments for `dev` and `prod`.

## Target architecture

```text
Single Azure subscription
├── rg-github-oidc
│   └── id-github-terraform
│       ├── federated credential for GitHub environment dev
│       └── federated credential for GitHub environment prod
└── workload resource groups
    ├── rg-myproject-dev
    └── rg-myproject-prod
```

## 1. Open the repo in Codespaces or a Dev Container

The devcontainer installs:

- Terraform CLI
- Azure CLI
- GitHub CLI

## 2. Authenticate locally

```bash
az login
az account set --subscription "<subscription-id>"
```

Confirm the active subscription:

```bash
az account show --query "{name:name, id:id, tenantId:tenantId}" -o table
```

## 3. Configure bootstrap variables

```bash
cp bootstrap/github-oidc/terraform.tfvars.example bootstrap/github-oidc/terraform.tfvars
```

Edit `bootstrap/github-oidc/terraform.tfvars`:

```hcl
subscription_id     = "<azure-subscription-id>"
tenant_id           = "<azure-tenant-id>"
location            = "westeurope"
github_organization = "<github-org-or-user>"
github_repository   = "<repo-name>"

identity_name = "id-github-terraform"
github_environments = ["dev", "prod"]
```

## 4. Run the bootstrap Terraform

```bash
cd bootstrap/github-oidc
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Save the outputs:

```bash
terraform output
```

You need these output values:

- `azure_client_id`
- `azure_tenant_id`
- `azure_subscription_id`


## 5. Create GitHub Environments

In GitHub, create two Environments:

- `dev`
- `prod`

For `prod`, configure required reviewers before deployments are allowed.

## 6. Add GitHub Environment variables

Add these variables to both the `dev` and `prod` GitHub Environments:

```text
AZURE_CLIENT_ID       = <bootstrap output azure_client_id>
AZURE_TENANT_ID       = <bootstrap output azure_tenant_id>
AZURE_SUBSCRIPTION_ID = <bootstrap output azure_subscription_id>
```

These are not secrets. They are identifiers used with OIDC. Do not create or store an Azure client secret.

## 7. Configure local tfvars

```bash
cd ../..
cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars
cp environments/prod/terraform.tfvars.example environments/prod/terraform.tfvars
```

Edit both files and set your actual subscription ID and resource group names.

## 8. Initialize and test locally

```bash
./scripts/tf.sh fmt
./scripts/tf.sh init dev
./scripts/tf.sh validate dev
./scripts/tf.sh plan dev
```

Prod:

```bash
./scripts/tf.sh init prod
./scripts/tf.sh validate prod
./scripts/tf.sh plan prod
```

## 9. Push to GitHub

On pull requests, `.github/workflows/terraform-plan.yml` runs plans for `dev` and `prod`.

On push to `main`, `.github/workflows/terraform-apply.yml` applies `dev`.

For `prod`, run the `Terraform apply` workflow manually and select `prod`. The GitHub `prod` Environment should require approval.

## Notes

- Keep `dev` and `prod` in separate Terraform state files.
- The same managed identity is used for both environments.
- Production safety is enforced through GitHub Environment protection.
- For stricter isolation later, split the single identity into separate `dev` and `prod` identities.
