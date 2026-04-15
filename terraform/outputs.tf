output "teams" {
  description = "Équipes créées avec leur ID"
  value = {
    for slug, team in github_team.teams : slug => {
      id   = team.id
      name = team.name
    }
  }
}

output "repositories" {
  description = "Repos créés avec leur URL"
  value = {
    for name, repo in github_repository.repos : name => {
      full_name  = repo.full_name
      html_url   = repo.html_url
      ssh_url    = repo.ssh_clone_url
      visibility = repo.visibility
    }
  }
}

output "org_variables" {
  description = "Actions variables créées au niveau de l'organisation"
  value       = [for v in github_actions_organization_variable.variables : v.variable_name]
}

output "org_webhooks" {
  description = "Webhooks actifs au niveau de l'organisation"
  value = {
    for k, wh in github_organization_webhook.webhooks : k => {
      url    = wh.configuration[0].url
      events = wh.events
      active = wh.active
    }
  }
}
