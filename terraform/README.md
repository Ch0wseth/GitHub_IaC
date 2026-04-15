# Terraform — GitHub Provider

Gestion de l'organisation **Ch0wseth** via le provider Terraform [`integrations/github`](https://registry.terraform.io/providers/integrations/github/latest/docs).

## Fichiers

| Fichier | Contenu |
|---------|---------|
| `main.tf` | Configuration du provider et du backend |
| `variables.tf` | Déclaration de toutes les variables |
| `teams.tf` | Équipes, membres de l'org, appartenance aux équipes |
| `repos.tf` | Repos et branch protections |
| `actions.tf` | Actions variables et secrets au niveau de l'org |
| `webhooks.tf` | Webhooks de l'organisation |
| `outputs.tf` | Valeurs en sortie |
| `terraform.tfvars.example` | Exemple de configuration à copier |

## Prérequis

### Token GitHub

Personal Access Token avec les scopes :
- `admin:org` — gérer les équipes et membres
- `repo` — gérer les repos

### Backend

Par défaut, le state est stocké localement. Pour un usage en équipe, configurer un backend dans `main.tf` :

```hcl
backend "azurerm" {
  resource_group_name  = "rg-tfstate"
  storage_account_name = "tfstate"
  container_name       = "github-iac"
  key                  = "github.tfstate"
}
```

## Utilisation

```bash
cd terraform

# 1. Copier et renseigner les variables
cp terraform.tfvars.example terraform.tfvars

# 2. Initialiser
terraform init

# 3. Voir ce qui va être créé/modifié
terraform plan

# 4. Appliquer
terraform apply
```

## Ce qui est géré

### Équipes (`teams.tf`)

```hcl
teams = {
  "developers" = {
    description = "Équipe développeurs"
    privacy     = "closed"
    parent_team = null
  }
  "platform-frontend" = {
    description = "Sous-équipe frontend"
    privacy     = "closed"
    parent_team = "platform"   # équipe parente
  }
}
```

### Repos (`repos.tf`)

```hcl
repositories = {
  "mon-repo" = {
    visibility     = "private"
    default_branch = "main"
    branch_protections = [
      {
        pattern            = "main"
        enforce_admins     = true
        required_approvals = 1
      }
    ]
  }
}
```

### Actions Variables (`actions.tf`)

```hcl
org_variables = {
  "GITHUB_ORG" = { value = "Ch0wseth", visibility = "all" }
}
```

> Les secrets Actions ne doivent jamais être stockés en clair. Utiliser SOPS, HashiCorp Vault ou AWS SSM pour chiffrer les valeurs avant de les mettre dans `tfvars`.

### Webhooks (`webhooks.tf`)

```hcl
org_webhooks = {
  "slack" = {
    url    = "https://hooks.slack.com/services/..."
    events = ["push", "pull_request"]
    active = true
  }
}
```

## Référence

### Provider & ressources

| Ressource | Documentation |
|-----------|---------------|
| Provider `integrations/github` | [registry.terraform.io](https://registry.terraform.io/providers/integrations/github/latest/docs) |
| `github_team` | [docs/resources/team](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team) |
| `github_team_membership` | [docs/resources/team_membership](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_membership) |
| `github_membership` | [docs/resources/membership](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/membership) |
| `github_repository` | [docs/resources/repository](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) |
| `github_branch_default` | [docs/resources/branch_default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_default) |
| `github_branch_protection` | [docs/resources/branch_protection](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection) |
| `github_actions_organization_variable` | [docs/resources/actions_organization_variable](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_variable) |
| `github_actions_organization_secret` | [docs/resources/actions_organization_secret](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_secret) |
| `github_organization_webhook` | [docs/resources/organization_webhook](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_webhook) |

### GitHub API & scopes

- [Scopes des Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
- [Créer un fine-grained PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token)
- [Création d'un PAT classic](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic)
- [Événements disponibles pour les webhooks](https://docs.github.com/en/webhooks/webhook-events-and-payloads)
- [Journal d'audit de l'organisation](https://docs.github.com/en/organizations/keeping-your-organization-secure/managing-security-settings-for-your-organization/reviewing-the-audit-log-for-your-organization)
- [GitHub Actions — Secrets chiffrés](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions)

### Terraform

- [Backends disponibles](https://developer.hashicorp.com/terraform/language/backend)
- [Importer des ressources existantes](https://developer.hashicorp.com/terraform/cli/import)
- [Commande `terraform state`](https://developer.hashicorp.com/terraform/cli/commands/state)
- [Changelog du provider GitHub](https://github.com/integrations/terraform-provider-github/blob/main/CHANGELOG.md)
- [Chiffrement des secrets Terraform avec SOPS](https://github.com/getsops/sops)
- [Versions de Terraform](https://releases.hashicorp.com/terraform/)

