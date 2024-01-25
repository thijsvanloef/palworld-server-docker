# Palworld Helm Chart

Allows you to deploy the usage of [Palworld Server docker](https://github.com/Filipe-Souza/palworld-server-docker) as
a helm chart and with helm deployments.

This is an advanced method of installation and can be quite difficult to non-technical trying to set it up.

## Dependencies

You will need the [Helm client](https://helm.sh/docs/intro/install/) and a Kubernetes cluster.

## Install the chart

There is no helm package available yet, so you need to clone this repo and setup it manually, or with some GitOps tool
like ArgoCD/FluxCD.

After cloning the repository, you can create a new file, e.g.: values.override.yaml to store your custom values.

After copying, modify your values.override.yaml as needed. You can look up the
[values summary](VALUES_SUMMARY.md) to see the parameter documentation.

After that, you can apply the chart:

```bash
helm install --create-namespace --namespace palworld palworld chart/ --values values.override.yaml
```

You can remove all the resources created (except the PVC) with the following command:

```bash
helm uninstall -n palworld palworld
```
