# Copilot Policies — Audit

Ce dossier contient les outils pour **lire et auditer** les policies Copilot Business de l'organisation.

> ⚠️ **Limitation API** : GitHub ne fournit pas d'API REST pour *modifier* ces policies.
> Toute modification doit être effectuée via l'interface GitHub :
> **Org Settings → Copilot → Policies**

---

## Policies disponibles en lecture

| Champ | Description |
|-------|-------------|
| `plan_type` | Type de plan (`business`, `enterprise`) |
| `seat_management_setting` | Qui peut utiliser Copilot (`assign_selected`, `all_members`) |
| `ide_chat` | Copilot Chat dans l'IDE (`enabled`, `disabled`, `unconfigured`) |
| `platform_chat` | Copilot Chat sur GitHub.com (`enabled`, `disabled`, `unconfigured`) |
| `cli` | Copilot CLI (`enabled`, `disabled`, `unconfigured`) |
| `public_code_suggestions` | Suggestions basées sur du code public (`allow`, `block`) |
| `seat_breakdown` | Répartition des sièges (total, actifs, inactifs, en attente) |

---

## Workflow automatisé

Le workflow [copilot-policies-audit.yml](../.github/workflows/copilot-policies-audit.yml) :
- S'exécute **tous les lundis à 8h** (UTC)
- Peut être déclenché manuellement via `workflow_dispatch`
- Affiche les résultats dans le **Job Summary** de GitHub Actions

### Secrets et variables requis

| Nom | Type | Scope PAT requis |
|-----|------|-----------------|
| `COPILOT_ADMIN_TOKEN` | Secret | `manage_billing:copilot` ou `read:org` |
| `GITHUB_ORG` | Variable | — |

---

## Script PowerShell local

```powershell
.\copilot-policies\Get-CopilotPolicies.ps1 -Org "my-org" -Token "ghp_..."
```

### Paramètres

| Paramètre | Obligatoire | Description |
|-----------|-------------|-------------|
| `-Org` | ✅ | Nom de l'organisation GitHub |
| `-Token` | ✅ | PAT avec scope `manage_billing:copilot` ou `read:org` |

---

## API utilisée

```
GET https://api.github.com/orgs/{org}/copilot/billing
```

Headers :
```
Accept: application/vnd.github+json
Authorization: Bearer <token>
X-GitHub-Api-Version: 2026-03-10
```

### Exemple de réponse

```json
{
  "seat_breakdown": {
    "total": 50,
    "added_this_cycle": 5,
    "pending_invitation": 0,
    "pending_cancellation": 0,
    "active_this_cycle": 42,
    "inactive_this_cycle": 8
  },
  "seat_management_setting": "assign_selected",
  "ide_chat": "enabled",
  "platform_chat": "enabled",
  "cli": "enabled",
  "public_code_suggestions": "block",
  "plan_type": "business"
}
```

---

## Références

- [API — Get Copilot seat and feature details for an organization](https://docs.github.com/en/rest/copilot/copilot-user-management?apiVersion=2026-03-10#get-copilot-seat-and-feature-details-for-an-organization)
- [Documentation Copilot Business — Policies](https://docs.github.com/en/copilot/managing-copilot/managing-github-copilot-in-your-organization/managing-policies-for-copilot-in-your-organization)
- [GitHub REST API — version 2026-03-10](https://docs.github.com/en/rest/about-the-rest-api/api-versions)
- [Créer un fine-grained PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token)
- [Scopes des PAT classic](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic)
- [GitHub Actions — Secrets chiffrés](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions)
- [Publier dans le Job Summary](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#adding-a-job-summary)
- [Journal d'audit de l'organisation](https://docs.github.com/en/organizations/keeping-your-organization-secure/managing-security-settings-for-your-organization/reviewing-the-audit-log-for-your-organization)
- [GitHub Copilot Business — Vue d'ensemble](https://docs.github.com/en/copilot/about-github-copilot/github-copilot-business-feature-accessibility)
