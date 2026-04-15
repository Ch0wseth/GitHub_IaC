terraform {
  required_version = ">= 1.9.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  # Décommenter et configurer selon votre backend
  # backend "s3" {}           # AWS S3
  # backend "azurerm" {}      # Azure Blob Storage
  # backend "gcs" {}          # Google Cloud Storage
  # backend "remote" {}       # Terraform Cloud / HCP Terraform
}

provider "github" {
  owner = var.github_org
  token = var.github_token
}
