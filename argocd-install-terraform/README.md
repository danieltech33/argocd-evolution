# Install Argo CD with Terraform

This directory contains a simple Terraform configuration to install Argo CD into a Kubernetes cluster. It's designed to be used with a local cluster like Minikube, assuming your `kubectl` is already configured to point to it.

## How to Use

1.  **Navigate to this directory:**
    ```bash
    cd argocd-install-terraform
    ```

2.  **Initialize Terraform:**
    This will download the required providers (Helm and Kubernetes).
    ```bash
    terraform init
    ```

3.  **Apply the Configuration:**
    This will create the `argocd` namespace and install the Argo CD Helm chart.
    ```bash
    terraform apply
    ```
    Type `yes` when prompted to confirm the changes.

## After Installation

Once `terraform apply` completes successfully, Argo CD will be running in your cluster.

### 1. Get the Initial Admin Password

Argo CD creates an initial password and stores it in a Kubernetes secret. To retrieve it, run:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
The default username is `admin`.

### 2. Access the Argo CD UI

To access the UI from your local machine, you can use `kubectl port-forward`:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
This command will run continuously. Now, open your web browser and navigate to:

**https://localhost:8080**

You can log in with the username `admin` and the password you retrieved in the previous step. Your browser may show a warning because the TLS certificate is self-signed; it is safe to proceed.

### 3. Apply Your ApplicationSet

Once you have logged into the UI, you can apply your `ApplicationSet` manifest to Argo CD:
```bash
kubectl apply -f ../argocd-manifests/applicationset.yaml
```
Argo CD will then start deploying your applications as defined in your repository. 