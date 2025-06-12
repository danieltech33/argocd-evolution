# argocd-install-terraform/providers.tf
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.13.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.30.0"
    }
  }
}

# The Helm provider is used to install charts
provider "helm" {
  kubernetes {
    # This assumes your kubectl is already configured to point to your minikube cluster
    config_path = "~/.kube/config"
  }
}

# The Kubernetes provider is used to create namespaces and other raw resources
provider "kubernetes" {
  # This assumes your kubectl is already configured to point to your minikube cluster
  config_path = "~/.kube/config"
} 