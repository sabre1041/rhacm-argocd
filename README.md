# Red Hat Advanced Cluster Management for Kubernetes and Argo CD

Approaches for integrating Red Hat Advanced Cluster Management and Argo CD.

## Scenarios

The following scenarios are available:

* [Deployment of Argo CD on RHACM Hub Cluster (Non RHACM Integrated)](#deploy-argo-cd)
* [Deployment of RHACM Hub via Argo CD](#deploy-red-hat-advanced-cluster-management-for-kubernetes)
* [Deployment of Cluster level Argo CD instances to managed RHACM clusters](#deployment-of-argo-cd-to-red-hat-advanced-cluster-management-to-managed-clusters)

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