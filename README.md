# Red Hat Advanced Cluster Management for Kubernetes and Argo CD
# This just to test

Approaches for integrating Red Hat Advanced Cluster Management and Argo CD.

## Scenarios

The following scenarios are available:

* [Deployment of Argo CD on RHACM Hub Cluster (Non RHACM Integrated)](#deploy-argo-cd)
* [Deployment of RHACM Hub via Argo CD](#deploy-red-hat-advanced-cluster-management-for-kubernetes)
* [Deployment of Cluster level Argo CD instances to managed RHACM clusters](#deployment-of-argo-cd-to-red-hat-advanced-cluster-management-to-managed-clusters)
* [Deployment of Namespace level Argo CD instances to managed RHACM clusters](#deployment-of-namespace-level-argo-cd-instances-to-managed-rhacm-clusters)

### Deployment of Red Hat Advanced Cluster Management Using Argo CD

This scenario makes use of Argo CD to deploy a Managed Hub of Red Hat Advanced Cluster Manager for Kubernetes. Assets are available to deploy a new instance or Argo CD or add to an existing deployment.

#### Deploy Argo CD

If a Argo CD instance is not already available, the following steps will provision one in the same cluster that will be designated to be the Red Hat Advanced Cluster Management for Kubernetes Hub cluster.

First, deploy the Argo CD Operator

```
$ oc apply -k rhacm-deploy/argocd-operator/base/
```

Next, deploy Argo CD.

```
$ oc apply -k rhacm-deploy/argocd/base/
```

#### Deploy Red Hat Advanced Cluster Management for Kubernetes

Once Argo CD is available, create an Argo CD Application to deploy Red Hat Advanced Cluster Management for Kubernetes Hub cluster.

Two Kustomize overlays are available which will config whether to deploy a Basic or HA Hub

##### HA Hub

```
oc apply -k rhacm-deploy/argocd-rhacm/overlays/ha/
```

##### Basic Hub

```
oc apply -k rhacm-deploy/argocd-rhacm/overlays/basic/
```


At this point, the Red Hat Advanced Cluster Management for Kubernetes Hub will deployed in the `open-cluster-management` namespace

### Deployment of Argo CD to Red Hat Advanced Cluster Management to Managed Clusters

Red Hat Advanced Cluster Management for Kubernetes can also enforce that each managed cluster be provisioned with an instance of Argo CD at a cluster level which can be used to manage the "last mile" configuration of the target cluster.

The following are a set of assets that make use of Red Hat Advanced Cluster Management for Kubernetes Policies to deploy the [Argo CD Operator](https://argocd-operator.readthedocs.io/en/latest/reference/argocd/#) to provision an instance of Argo CD.

The associated policies will be provisioned on the Hub cluster and target managed clusters that contain the label `argocd=true`.

Execute the following command to apply the `Subscription` to the Hub cluster

```
$ oc apply -k rhacm-managed-argocd/argocd-cluster/subscription/ 
```

In a few moments, Argo CD will be provisioned on all clusters with the label `argocd=true`.

### Deployment of Namespace Scoped Argo CD to Red Hat Advanced Cluster Management to Managed Clusters

Red Hat Advanced Cluster Management for Kubernetes can also enforce that each managed cluster be provisioned with a namespace scoped instance of Argo CD to manage the "last mile" configuration of the target cluster. Typical deployments of ArgoCD are managed at a cluster scoped level. However, in many multitenant environments, it may be desired to limit the level of access granted.

The following are a set of assets that make use of Red Hat Advanced Cluster Management for Kubernetes Policies and application capabilities to deploy two separate instances of Argo CD using a [Helm chart](https://helm.sh/) at a namespace scope. This approach simulates how two independent teams can make use of separate instances of Argo CD within the same cluster in a secure fashion. It also showcases how ArgoCD namespace scoped configurations enables the management of resources across a set of namespaces.

The associated configurations will deploy a deploy resources to remote clusters with the label `argocd-namespaced=true`:

1. Policies to deliver Argo CD Custom Resource Definitions
2. Deploy two (2) separate deployments of Argo CD at a namespace scope
    1. Each deployment will consist of two namespaces (One will contain Argo CD and another that can be used to simulate a production only namespace)

Execute the following command to apply the resources to the Hub cluster

```
$ oc apply -k rhacm-managed-argocd/argocd-namespaced/resources/ 
```

The following namespaces will be provisioned on the target cluster(s):

* argocd-1
* argocd-1-prod
* argocd-2
* argocd-2-prod
