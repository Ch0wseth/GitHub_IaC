# GitHub IaC — Copilot Business

Infrastructure as Code pour gérer l'organisation **Ch0wseth** et les politiques **GitHub Copilot Business** via l'API GitHub REST et Terraform.

## Structure

```
.
├── .github/
│   └── workflows/
│       ├── content-exclusion-apply.yml   # GET et SET des règles d'exclusion Copilot
│       └── copilot-policies-audit.yml    # Audit hebdomadaire des politiques Copilot
├── content-exclusion/
│   ├── config.json                       # Patterns exclus de Copilot (par repo)
│   ├── Apply-ContentExclusion.ps1        # Script GET/SET via API REST
│   └── README.md
├── copilot-policies/
│   ├── Get-CopilotPolicies.ps1           # Audit des politiques et du billing Copilot
│   └── README.md
├── terraform/
│   ├── main.tf                           # Provider GitHub + backend
│   ├── variables.tf                      # Toutes les variables
│   ├── teams.tf                          # Équipes et membres
│   ├── repos.tf                          # Repos et branch protections
│   ├── actions.tf                        # Variables et secrets Actions
│   ├── webhooks.tf                       # Webhooks de l'organisation
│   ├── outputs.tf                        # Valeurs en sortie
│   ├── terraform.tfvars.example          # Exemple de configuration
│   └── README.md
└── README.md
```

---

## Modules

### `content-exclusion/` — Exclusion de contenu Copilot

Gère les fichiers et patterns que Copilot **ne doit pas lire** ni utiliser pour ses suggestions, au niveau de l'organisation.

| Élément | Détail |
|---------|--------|
| Config | `content-exclusion/config.json` — map `{ "repo": ["pattern"] }`, `"*"` pour tous les repos |
| Script | `Apply-ContentExclusion.ps1` — params `-Org`, `-Token`, `-Action [Get\|Set]`, `-DryRun` |
| API | `GET/PUT /orgs/{org}/copilot/content_exclusion` |
| API version | `2026-03-10` |
| Scope PAT | `copilot` |

**Workflow :** push sur `main` → `set` automatique ; `workflow_dispatch` disponible pour `get` ou `set`.

```powershell
# Lire la config en place
.\Apply-ContentExclusion.ps1 -Org "Ch0wseth" -Token $env:GH_TOKEN -Action Get

# Appliquer (dry run)
.\Apply-ContentExclusion.ps1 -Org "Ch0wseth" -Token $env:GH_TOKEN -Action Set -DryRun

# Appliquer
.\Apply-ContentExclusion.ps1 -Org "Ch0wseth" -Token $env:GH_TOKEN -Action Set
```

**Secrets/Variables à configurer dans l'org GitHub :**

| Nom | Type | Scope PAT |
|-----|------|-----------|
| `COPILOT_ADMIN_TOKEN` | Secret | `copilot` |
| `GITHUB_ORG` | Variable | — |

---

### `copilot-policies/` — Audit des politiques Copilot

Lit en lecture seule les politiques Copilot et le billing de l'organisation.

| Élément | Détail |
|---------|--------|
| Script | `Get-CopilotPolicies.ps1` — params `-Org`, `-Token` |
| API | `GET /orgs/{org}/copilot/billing` |
| API version | `2026-03-10` |
| Scope PAT | `manage_billing:copilot` ou `read:org` |

**Données retournées :** `plan_type`, `seat_management_setting`, `ide_chat`, `platform_chat`, `cli`, `public_code_suggestions`, `seat_breakdown`.

**Workflow :** audit automatique tous les **lundis à 8h UTC** + `workflow_dispatch`. Résultats publiés en Job Summary (tableau Markdown).

> Les feature policies (`ide_chat`, `platform_chat`, `cli`, `public_code_suggestions`) sont **lecture seule** — aucune API de modification n'existe à ce jour. Idem pour la sélection des modèles et le model router.

---

### `terraform/` — Gestion de l'organisation GitHub

Gère l'organisation via le provider Terraform [`integrations/github ~> 6.0`](https://registry.terraform.io/providers/integrations/github/latest/docs).

| Fichier | Contenu |
|---------|---------|
| `main.tf` | Provider + backend (local par défaut, backends cloud commentés) |
| `variables.tf` | Teams, membres, repos, variables/secrets Actions, webhooks |
| `teams.tf` | `github_team`, `github_membership`, `github_team_membership` |
| `repos.tf` | `github_repository`, `github_branch_default`, `github_branch_protection` |
| `actions.tf` | `github_actions_organization_variable`, `github_actions_organization_secret` |
| `webhooks.tf` | `github_organization_webhook` |
| `outputs.tf` | Teams, repos (URLs), variables, webhooks |

**Scope PAT requis :** `admin:org`, `repo`

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Renseigner github_token et github_org dans terraform.tfvars

terraform init
terraform plan
terraform apply
```

Voir [`terraform/README.md`](terraform/README.md) pour la référence complète des variables et exemples de configuration.

---

## Limites API (UI uniquement)

Les éléments suivants ne sont **pas automatisables** via l'API GitHub à ce jour :

| Fonctionnalité | Statut |
|----------------|--------|
| Modification des feature policies (`ide_chat`, etc.) | GET uniquement |
| Sélection des modèles Copilot | Aucune API (ni REST, ni GraphQL) |
| Auto model selection / model router | Aucune API |

---

## Secrets et variables globaux

| Nom | Type | Utilisé par | Scope PAT |
|-----|------|-------------|-----------|
| `COPILOT_ADMIN_TOKEN` | Secret | `content-exclusion-apply.yml`, `copilot-policies-audit.yml` | `copilot`, `read:org` |
| `GITHUB_ORG` | Variable | Les deux workflows | — |

---

## Bonnes pratiques

### Gestion des secrets

- Ne jamais committer de tokens ou credentials en clair dans le dépôt
- Utiliser des GitHub Actions secrets pour les PAT (`COPILOT_ADMIN_TOKEN`)
- Pour Terraform, préférer une variable d'environnement (`TF_VAR_github_token`) ou un outil comme SOPS plutôt que de stocker le token dans `terraform.tfvars`
- Le fichier `terraform.tfvars` est dans `.gitignore` — ne pas le retirer

### Principe de moindre privilège

- Utiliser des PAT avec le **scope minimal** requis pour chaque usage (voir tableau des secrets)
- Préférer les **fine-grained PAT** aux classic PAT ; limiter l'accès à l'organisation cible uniquement
- Ne pas réutiliser le même token pour plusieurs workflows si les scopes diffèrent

### Modifications Copilot

- Toujours passer par une **PR** pour modifier `content-exclusion/config.json` — le merge déclenche l'application automatique
- Tester les changements avec `-DryRun` avant de les appliquer en production
- Les feature policies ne peuvent être modifiées que via l'UI GitHub : **Org Settings → Copilot → Policies**

### Terraform

- Toujours relire le diff de `terraform plan` avant un `terraform apply`
- En équipe, configurer un **backend distant** (Azure Blob, S3, GCS) pour partager le state et activer le state locking
- Ne pas modifier les ressources GitHub manuellement — cela crée un **drift** ; utiliser `terraform import` pour rattraper une ressource existante
- Les repos ont `prevent_destroy = true` : supprimer un repo nécessite une modification explicite du code
- Épingler les versions provider dans `required_providers` et committer `.terraform.lock.hcl` pour des déploiements reproductibles

---

## Références

### GitHub Copilot

- [GitHub Copilot Business — Vue d'ensemble](https://docs.github.com/en/copilot/about-github-copilot/github-copilot-business-feature-accessibility)
- [GitHub REST API — Copilot](https://docs.github.com/en/rest/copilot)
- [API Copilot — Content Exclusion](https://docs.github.com/en/rest/copilot/copilot-content-exclusion-management)
- [API Copilot — Billing & Policies](https://docs.github.com/en/rest/copilot/copilot-user-management)
- [Configurer le content exclusion pour une organisation](https://docs.github.com/en/copilot/managing-copilot/configuring-and-auditing-content-exclusion/excluding-content-from-github-copilot#configuring-content-exclusions-for-your-organization)
- [Gérer les policies Copilot pour une organisation](https://docs.github.com/en/copilot/managing-copilot/managing-github-copilot-in-your-organization/managing-policies-for-copilot-in-your-organization)
- [Versions de l'API REST GitHub](https://docs.github.com/en/rest/about-the-rest-api/api-versions)

### Authentification & sécurité

- [Créer un fine-grained PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token)
- [Scopes des PAT classic](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic)
- [GitHub Actions — Secrets chiffrés](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions)
- [Journal d'audit de l'organisation](https://docs.github.com/en/organizations/keeping-your-organization-secure/managing-security-settings-for-your-organization/reviewing-the-audit-log-for-your-organization)

### Terraform

- [Provider `integrations/github`](https://registry.terraform.io/providers/integrations/github/latest/docs)
- [Changelog du provider GitHub](https://github.com/integrations/terraform-provider-github/blob/main/CHANGELOG.md)
- [Backends Terraform disponibles](https://developer.hashicorp.com/terraform/language/backend)
- [Importer des ressources existantes (`terraform import`)](https://developer.hashicorp.com/terraform/cli/import)
- [Commande `terraform state`](https://developer.hashicorp.com/terraform/cli/commands/state)
- [Chiffrement des secrets Terraform avec SOPS](https://github.com/getsops/sops)

### GitHub Actions

- [Syntaxe des workflows](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions)
- [Événements déclencheurs de workflows](https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows)
- [Publier dans le Job Summary](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#adding-a-job-summary)
