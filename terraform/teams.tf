# ─── Équipes ──────────────────────────────────────────────────────────────────

resource "github_team" "teams" {
  for_each = var.teams

  name        = each.key
  description = each.value.description
  privacy     = each.value.privacy

  parent_team_id = each.value.parent_team != null ? github_team.teams[each.value.parent_team].id : null
}

# ─── Membres de l'organisation ────────────────────────────────────────────────

resource "github_membership" "members" {
  for_each = var.org_members

  username = each.key
  role     = each.value
}

# ─── Appartenance aux équipes ─────────────────────────────────────────────────

resource "github_team_membership" "memberships" {
  for_each = var.team_memberships

  team_id  = github_team.teams[each.value.team].id
  username = each.key
  role     = each.value.role

  depends_on = [github_membership.members]
}
