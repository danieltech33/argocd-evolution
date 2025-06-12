# Argo CD ApplicationSet with Kustomize and Environment-per-Folder

This directory contains the manifest for a sophisticated GitOps workflow that supports dynamic, per-developer environments. It uses an Argo CD `ApplicationSet` to discover "environment" folders and [Kustomize](https://kustomize.io/) to compose and configure the applications within them.

## Structure

-   `applicationset.yaml`: A single manifest that discovers and generates Argo CD `Application` resources for each environment.
-   `environments/`: A top-level directory where each subdirectory represents a complete, deployable environment.
    -   `production/`: Contains the Kustomize configuration for the production environment.
    -   `developer-namespace/`: Contains the Kustomize configuration for a developer's preview environment. This simulates an environment created by a CI pipeline for a pull request.

## How it Works

1.  **Environment Discovery**: The `ApplicationSet` uses a `git` generator to scan the `argocd-manifests/environments/` path. It creates an Argo CD Application for every subdirectory it finds.

2.  **Kustomize for Composition**: Each environment folder contains a `kustomization.yaml` file. This file is the source of truth for that environment. It defines:
    -   Which base Helm charts to deploy (e.g., `service-a`, `service-b-v2`).
    -   Which namespace all resources should be deployed into.
    -   Any environment-specific overrides, such as image tags, replica counts, or ingress hostnames.

3.  **Argo CD Application**: The `ApplicationSet` template points each generated application to the `kustomization.yaml` in the discovered environment folder. Argo CD then uses Kustomize to build the final manifests before applying them to the cluster.

## How to Use

1.  **Push to Git**: Make sure the entire project is pushed to a Git repository.

2.  **Apply the ApplicationSet**: The `applicationset.yaml` is now configured to use `https://github.com/danieltech33/argocd-evolution.git`. Apply it to your cluster:
    ```bash
    kubectl apply -f argocd-manifests/applicationset.yaml
    ```

3.  **Verify in Argo CD**: Open your Argo CD UI. It will discover the `ApplicationSet`, which will then scan your repository and automatically generate the `production` and `developer-namespace` applications.

## The Developer Workflow (CI/CD Simulation)

This setup enables a powerful "preview environment" workflow.

### To Add a Developer Environment:

A CI pipeline, triggered by a developer's pull request, would perform these steps automatically:

1.  Create a new environment directory (e.g., `argocd-manifests/environments/pr-123`).
2.  Create a `kustomization.yaml` inside that directory.
3.  The `kustomization.yaml` would point to the required service charts and apply patches to:
    -   Set the namespace to a unique value (e.g., `pr-123`).
    -   Set the image tag to the specific feature branch tag.
4.  Commit and push this new folder to the Git repository.

Argo CD's `ApplicationSet` will automatically discover the new `pr-123` folder and deploy the environment.

### To Remove a Developer Environment:

When the pull request is merged or closed, the CI pipeline would simply:

1.  Remove the `argocd-manifests/environments/pr-123` directory from Git.
2.  Commit and push the change.

Argo CD will see that the environment folder is gone and, because `prune: true` is set, it will automatically delete the corresponding Argo CD Application and all of its Kubernetes resources, cleaning up the environment completely. 