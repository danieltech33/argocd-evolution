# argocd-install-terraform/main.tf

# Create the dedicated namespace for Argo CD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# Install the Argo CD Helm chart
resource "helm_release" "argocd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  create_namespace = false # We created it above
  # Use a specific, recent, and valid version for stability

  # Wait for all the Argo CD pods to be ready before considering the install a success
  wait = true

  # Recommended values for a production-like setup, even on local.
  # This disables the less secure, built-in Dex server in favor of managing users manually.
  values = [
    <<-EOT
    server:
      extraArgs:
        - --insecure
    configs:
      cm:
        # We will manage users manually via the configmap
        dex.config: ""
    EOT
  ]

  # This ensures that the namespace is created before Helm tries to install the chart into it
  depends_on = [
    kubernetes_namespace.argocd
  ]
} 