# Content Exclusion — Copilot Business

Gestion des règles d'exclusion de contenu pour GitHub Copilot Business sur l'organisation **Ch0wseth**.

Les fichiers définis ici ne seront **jamais** envoyés à Copilot comme contexte, ni utilisés pour générer des suggestions.

## Fichiers

| Fichier | Rôle |
|---------|------|
| `config.json` | Règles d'exclusion (source de vérité) |
| `Apply-ContentExclusion.ps1` | Lecture et application manuelle en local |
| `../.github/workflows/content-exclusion-apply.yml` | Automatisation via GitHub Actions |

## Modifier les règles

Édite `config.json`, fais une PR, merge → appliqué automatiquement dans l'org.

```json
{
  "*": [
    "**/.env",
    "**/secrets/**"
  ]
}
```

La clé est le nom du repo. `*` s'applique à tous les repos de l'organisation.

### Cibler un repo spécifique

Pour exclure des fichiers uniquement dans un repo précis, ajouter une clé avec le nom du repo :

```json
{
  "*": ["**/.env"],
  "mon-repo": ["**/internal/**", "**/*.tfvars"]
}
```

## Script local (PowerShell)

### Lire les règles actuelles dans l'org

```powershell
.\Apply-ContentExclusion.ps1 -Org "Ch0wseth" -Token $env:GH_TOKEN -Action Get
```

### Appliquer config.json

```powershell
.\Apply-ContentExclusion.ps1 -Org "Ch0wseth" -Token $env:GH_TOKEN -Action Set
```

### Dry run — preview sans toucher à l'API

```powershell
.\Apply-ContentExclusion.ps1 -Org "Ch0wseth" -Token $env:GH_TOKEN -Action Set -DryRun
```

Le token doit avoir le scope `copilot`.

## GitHub Actions

Le workflow `.github/workflows/content-exclusion-apply.yml` expose deux jobs :

| Déclencheur | Job | Ce que ça fait |
|-------------|-----|----------------|
| Push vers `main` | `set` | Applique `config.json` dans l'org |
| `workflow_dispatch` → action `get` | `get` | Lit et affiche les règles actuelles (visible dans le Job Summary) |
| `workflow_dispatch` → action `set` | `set` | Applique `config.json` manuellement |

## Prérequis GitHub Actions

À configurer dans **Settings → Secrets and variables → Actions** de l'organisation :

| Nom | Type | Valeur |
|-----|------|--------|
| `COPILOT_ADMIN_TOKEN` | Secret | PAT avec scope `copilot` |
| `GITHUB_ORG` | Variable | `Ch0wseth` |

## Référence

### API GitHub

| Endpoint | Description |
|----------|-------------|
| [`GET /orgs/{org}/copilot/content_exclusion`](https://docs.github.com/en/rest/copilot/copilot-content-exclusion-management#get-copilot-content-exclusion-rules-for-an-organization) | Lire les règles actuelles |
| [`PUT /orgs/{org}/copilot/content_exclusion`](https://docs.github.com/en/rest/copilot/copilot-content-exclusion-management#set-copilot-content-exclusion-rules-for-an-organization) | Appliquer les règles |

> Version API : `2026-03-10`

### Documentation GitHub

- [Configurer le content exclusion pour une organisation](https://docs.github.com/en/copilot/managing-copilot/configuring-and-auditing-content-exclusion/excluding-content-from-github-copilot#configuring-content-exclusions-for-your-organization)
- [Créer un fine-grained PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token)
- [Scopes des PAT classic](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic) — scope requis : `copilot`
- [Événements de webhook disponibles](https://docs.github.com/en/webhooks/webhook-events-and-payloads) _(pour les workflows Actions)_
- [Syntaxe des glob patterns](https://docs.github.com/en/copilot/managing-copilot/configuring-and-auditing-content-exclusion/excluding-content-from-github-copilot#about-content-exclusions-for-github-copilot)
- [Versions de l'API REST GitHub](https://docs.github.com/en/rest/about-the-rest-api/api-versions)
- [GitHub Actions — Secrets chiffrés](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions)
- [Syntaxe des workflows GitHub Actions](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions)
- [Publier dans le Job Summary](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#adding-a-job-summary)
- [Journal d'audit de l'organisation](https://docs.github.com/en/organizations/keeping-your-organization-secure/managing-security-settings-for-your-organization/reviewing-the-audit-log-for-your-organization)
