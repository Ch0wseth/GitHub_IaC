# ─── Repos ────────────────────────────────────────────────────────────────────

resource "github_repository" "repos" {
  for_each = var.repositories

  name        = each.key
  description = each.value.description
  visibility  = each.value.visibility

  has_issues   = each.value.has_issues
  has_projects = each.value.has_projects
  has_wiki     = each.value.has_wiki

  auto_init = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_branch_default" "default" {
  for_each = var.repositories

  repository = github_repository.repos[each.key].name
  branch     = each.value.default_branch
}

# ─── Branch protections ───────────────────────────────────────────────────────

locals {
  branch_protections = flatten([
    for repo_name, repo in var.repositories : [
      for bp in repo.branch_protections : {
        key                    = "${repo_name}/${bp.pattern}"
        repo                   = repo_name
        pattern                = bp.pattern
        enforce_admins         = bp.enforce_admins
        require_signed_commits = bp.require_signed_commits
        required_approvals     = bp.required_approvals
      }
    ]
  ])
}

resource "github_branch_protection" "protections" {
  for_each = { for bp in local.branch_protections : bp.key => bp }

  repository_id = github_repository.repos[each.value.repo].node_id
  pattern       = each.value.pattern

  enforce_admins         = each.value.enforce_admins
  require_signed_commits = each.value.require_signed_commits

  required_pull_request_reviews {
    required_approving_review_count = each.value.required_approvals
  }
}
