# ─── Organisation ─────────────────────────────────────────────────────────────

variable "github_org" {
  description = "Nom de l'organisation GitHub"
  type        = string
}

variable "github_token" {
  description = "Personal Access Token. Scopes requis : admin:org, repo"
  type        = string
  sensitive   = true
}

# ─── Équipes ──────────────────────────────────────────────────────────────────

variable "teams" {
  description = "Équipes à créer dans l'organisation"
  type = map(object({
    description = string
    privacy     = string # closed | secret
    parent_team = optional(string)
  }))
  default = {}
}

# ─── Membres ──────────────────────────────────────────────────────────────────

variable "org_members" {
  description = "Membres de l'organisation avec leur rôle (member | admin)"
  type        = map(string) # { "username" = "member" | "admin" }
  default     = {}
}

variable "team_memberships" {
  description = "Appartenance des membres aux équipes"
  type = map(object({
    team = string
    role = string # member | maintainer
  }))
  default = {}
}

# ─── Repos ────────────────────────────────────────────────────────────────────

variable "repositories" {
  description = "Repos à créer/gérer dans l'organisation"
  type = map(object({
    description    = optional(string, "")
    visibility     = optional(string, "private") # public | private | internal
    has_issues     = optional(bool, true)
    has_projects   = optional(bool, false)
    has_wiki       = optional(bool, false)
    default_branch = optional(string, "main")
    branch_protections = optional(list(object({
      pattern                = string
      enforce_admins         = optional(bool, false)
      require_signed_commits = optional(bool, false)
      required_approvals     = optional(number, 1)
    })), [])
  }))
  default = {}
}

# ─── Actions ──────────────────────────────────────────────────────────────────

variable "org_variables" {
  description = "Actions variables au niveau de l'organisation"
  type = map(object({
    value      = string
    visibility = optional(string, "all") # all | private | selected
  }))
  default = {}
}

variable "org_secrets" {
  description = "Actions secrets au niveau de l'organisation (valeurs chiffrées via SOPS ou Vault)"
  type = map(object({
    encrypted_value = string
    visibility      = optional(string, "all")
  }))
  default = {}
}

# ─── Webhooks ─────────────────────────────────────────────────────────────────

variable "org_webhooks" {
  description = "Webhooks au niveau de l'organisation"
  type = map(object({
    url          = string
    content_type = optional(string, "json")
    events       = list(string)
    active       = optional(bool, true)
  }))
  default = {}
}
