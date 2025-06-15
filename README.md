# ArgoCD Environment Management

This repository implements a hierarchical environment management structure for ArgoCD that provides:

1. Visual organization of applications by environment in the ArgoCD UI
2. Flexibility to configure services via `config.json` files
3. Automated discovery and deployment of environments
4. Centralized ingress configuration

## Structure

```
argocd-manifests/
├── applicationset.yaml          # Top-level ApplicationSet that discovers environments
├── environments/
│   ├── production/
│   │   └── config.json          # Configuration for production services
│   ├── developer/
│   │   └── config.json          # Configuration for developer services
│   └── pr-123/
│       └── config.json          # Configuration for PR-specific services
└── helm-charts/
    └── app-of-apps-generator/   # Helm chart that generates child applications
        ├── templates/
        │   └── child-apps.yaml  # Template for generating applications
        └── values.yaml          # Default values (overridden by config.json)
```

## How It Works

1. The `applicationset.yaml` discovers environment directories and creates parent applications
2. Each parent application uses the `app-of-apps-generator` chart with its environment's `config.json`
3. The generator chart creates child applications for each service defined in `config.json`
4. This creates a hierarchy in the ArgoCD UI:
   - Environment (e.g., "production")
     - Service (e.g., "production-service-a")

## Adding a New Environment

1. Create a new directory under `environments/` (e.g., `environments/staging/`)
2. Add a `config.json` file with your service configurations:

```json
{
  "global": {
    "domain": "staging.example.com"
  },
  "services": [
    {
      "service_name": "service-a",
      "namespace": "staging",
      "chart_path": "blue-green-helm/charts/service-a",
      "image_tag": "stable"
    }
  ]
}
```

3. The ApplicationSet will automatically discover and deploy the new environment

## Adding a New Service to an Environment

Simply add a new entry to the environment's `config.json` file:

```json
"services": [
  {
    "service_name": "new-service",
    "namespace": "production",
    "chart_path": "blue-green-helm/charts/new-service",
    "image_tag": "stable"
  }
]
```

## Removing a Service from an Environment

Remove the service's entry from the environment's `config.json` file. ArgoCD will automatically remove the deployed resources.

## CI/CD Integration

For CI/CD integration, your pipeline can:

1. Create/update environment directories and config.json files
2. Push changes to the Git repository
3. ArgoCD will automatically detect changes and apply them

For cleanup, the CI/CD pipeline can:

1. Remove the environment directory
2. ArgoCD will automatically remove all associated resources 