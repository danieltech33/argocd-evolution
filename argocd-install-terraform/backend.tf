# argocd-install-terraform/backend.tf

# Explicitly configure the local backend.
# This ensures that Terraform stores the state file in the local filesystem.
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
} 