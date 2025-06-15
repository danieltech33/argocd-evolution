# Blue/Green Deployment with Helm

This project demonstrates a repository structure for managing multiple microservices with Helm, designed to facilitate blue/green deployments.

## Repository Structure

The repository is structured as a Helm chart monorepo:

-   `blue-green-helm/`: The root of the umbrella Helm chart.
    -   `Chart.yaml`: Defines the umbrella chart and its dependencies (`service-a`, `service-b`).
    -   `values.yaml`: Contains global values, including the `deploymentColor` for blue/green deployments.
    -   `charts/`: This directory contains the individual microservice charts.
        -   `service-a/`: The Helm chart for `service-a`.
            -   `Chart.yaml`: Metadata for the `service-a` chart.
            -   `values.yaml`: Default values for `service-a`.
            -   `templates/`: Kubernetes manifests for `service-a`.
                -   `deployment.yaml`: The deployment manifest, which uses the `deploymentColor` value.
                -   `service.yaml`: The service manifest.
        -   `service-b/`: The Helm chart for `service-b`, with the same structure as `service-a`.

## Blue/Green Deployment Strategy

The blue/green deployment strategy is controlled by the `deploymentColor` value. Each microservice's deployment has a `color` label that is set by this value.

The `color` is determined by the following priority (using the `coalesce` function in the templates):

1.  A value set specifically for the service in the parent chart's `values.yaml` (e.g., `service-a.deploymentColor: green`).
2.  A global value set in the parent chart's `values.yaml` (`global.deploymentColor: green`).
3.  A default value in the service's own `values.yaml`.

### How to Use

1.  **Install the chart (Blue deployment):**

    By default, the `global.deploymentColor` is set to `blue`. To deploy the "blue" version of all services, navigate to the `blue-green-helm` directory and run:

    ```bash
    helm install my-app .
    ```

    This will create deployments and pods with the label `color: "blue"`.

2.  **Deploy the "Green" version:**

    To deploy the "green" version, you can upgrade the Helm release and set the `global.deploymentColor` to `green`.

    ```bash
    helm upgrade my-app . --set global.deploymentColor=green
    ```

    This will trigger a rolling update of the deployments, creating new pods with the label `color: "green"`. The old "blue" pods will be terminated.

3.  **Granular Control:**

    If you want to deploy a "green" version of only `service-a`, you can override the value for that specific service:

    ```bash
    helm upgrade my-app . --set service-a.deploymentColor=green
    ```

    In this case, `service-a` will be "green" while `service-b` (and any others) will remain "blue".

### Traffic Switching

This example focuses on changing the deployment color. In a real-world scenario, you would also need a mechanism to switch user traffic from the "blue" version to the "green" version. This is typically done with a Kubernetes Service, Ingress controller, or a service mesh (like Istio or Linkerd) that can manage traffic routing based on labels.

For example, you could have a `stable` service that always points to the active deployment. You would update this service's selector to point to the new color after you have verified that the new deployment is healthy. 