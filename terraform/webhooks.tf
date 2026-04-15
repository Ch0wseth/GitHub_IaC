# ─── Webhooks (org) ───────────────────────────────────────────────────────────

resource "github_organization_webhook" "webhooks" {
  for_each = var.org_webhooks

  active = each.value.active
  events = each.value.events

  configuration {
    url          = each.value.url
    content_type = each.value.content_type
    insecure_ssl = false
  }
}
