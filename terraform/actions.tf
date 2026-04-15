# ─── Actions Variables (org) ──────────────────────────────────────────────────

resource "github_actions_organization_variable" "variables" {
  for_each = var.org_variables

  variable_name = each.key
  visibility    = each.value.visibility
  value         = each.value.value
}

# ─── Actions Secrets (org) ────────────────────────────────────────────────────
# Les valeurs sont des secrets déjà chiffrés (ex: via SOPS, Vault ou AWS SSM).
# Ne jamais stocker de secrets en clair dans les tfvars.

resource "github_actions_organization_secret" "secrets" {
  for_each = var.org_secrets

  secret_name     = each.key
  visibility      = each.value.visibility
  encrypted_value = each.value.encrypted_value
}
