# argocd-install-terraform/main.tf

# Create the dedicated namespace for Argo CD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# Create namespace for nginx-ingress
resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

# Install the NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = kubernetes_namespace.ingress_nginx.metadata[0].name
  create_namespace = false # We created it above
  version          = "4.8.3"  # Use a specific, recent version

  set {
    name  = "controller.service.type"
    value = "NodePort"  # For local Minikube/Docker Desktop use
  }

  # Wait for the ingress controller to be ready
  wait = true

  depends_on = [
    kubernetes_namespace.ingress_nginx
  ]
}

# Install the Argo CD Helm chart
resource "helm_release" "argocd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  create_namespace = false # We created it above
  version          = "5.51.6" # Use a specific, recent, and valid version for stability

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
    kubernetes_namespace.argocd,
    helm_release.nginx_ingress  # Ensure ingress controller is installed first
  ]
} 