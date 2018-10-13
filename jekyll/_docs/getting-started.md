---
layout: doc
title: Getting Started
subtitle: Installing fim-k8s in your Kubernetes cluster
tags: introduction fimwatcher
---

**fim-k8s** works by configuring a custom Kubernetes resource that defines
paths and events that you want to be notified about for your current
deployments. This custom resource, in conjunction with a cluster controller
running and listening for lifecycle events, is responsible for maintaining a
source of truth between the state of the cluster and the daemons listening for
filesystem events on each node.

## Quickstart

In order to properly run these components, a Kubernetes cluster running v1.9 or
above is required. Depending on your environment, there may be additional
requirements to run both the daemon as a privileged container and the
controller with an appropriate level of access to receive cluster events. A
multi-tenancy environment will likely not allow for this kind of entitlement.

We provide multiple paths of configuration for both vanilla Kubernetes and
OpenShift, which has additional security measures in place.

{% codetabs %}
{% codetab Kubernetes %}
To deploy **fim-k8s** on a vanilla Kubernetes environment, simply run an
`apply` on the following hosted configuration:

```shell
kubectl apply -f \
  https://raw.githubusercontent.com/clustergarage/fim-k8s/master/configs/fim-k8s.yaml
```

This will create a `Namespace` **fim** under which all the components will be
organized.
{% endcodetab %}
{% codetab OpenShift %}
OpenShift has a more opinionated security model by default. We assume a normal
OpenShift install, which requires a few more components to be created. This can
be done with the following command:

```shell
oc apply -f \
  https://raw.githubusercontent.com/clustergarage/fim-k8s/master/configs/fim-openshift.yaml
```

This will create an OpenShift `Project` **fim** under which all components will
be organized. In addition to creating a `Namespace`, an OpenShift project needs
various `RoleBindings` for building and pulling images via an `ImageStream` and
for our `ServiceAccount` to have an admin role reference. OpenShift also
requires `SecurityContextConstraints` to properly run containers as certain
users, as a privileged container, and gain access to the host PID namespace and
volume.
{% endcodetab %}
{% codetab Helm %}
To install using a Helm chart, we provide a couple ways to do this. The
simplest being an archive file included in each release:

```shell
helm install \
  https://github.com/clustergarage/fim-k8s/releases/download/v0.1.0/fim-k8s-0.1.0.tgz
```

The other way is to add a Helm repository to your cluster and update/install
using these mechanisms:

```shell
helm repo add clustergarage \
  https://raw.githubusercontent.com/clustergarage/fim-k8s/master/helm/
helm repo update
helm install clustergarage/fim-k8s
```

This will create a `Namespace` **fim** under which all the components will be
organized.
{% endcodetab %}
{% endcodetabs %}

Under the **fim** namespace is a `ServiceAccount` used to run all items of
fim-k8s; this service account will also get a `ClusterRoleBinding` with
settings that allow the controller and daemon to be run with their required
privileges.

A `CustomResourceDefinition` is included to define a custom **FimWatcher**
type housing the pod selector, paths, events, and optional flags for the
watcher.

Finally, the **fimcontroller** `Deployment` and **fimd** `DaemonSet` are the
core of the product. There is a headless `Service` used to communicate between
the controller and all instances of the daemons.

> You can verify that it installed properly by inspecting `kubectl -n fim get
all`

All pods should eventually converge into `Running` state. The daemon pods in
particular should be running on each node that run workloads you wish to be
notified on. The controller is suggested to run with a single replica, as all
method calls to the daemon are idempotent; it can still function properly with
\>1 replicas, however.

## Need Help?

If you have any issues with any of the steps to get started with running this
in your cluster, please begin by checking to see if any of the issues you may
be facing are included in our
[GitHub issues](https://github.com/clustergarage/fim-k8s/issues). If you
suspect you may be having problems not recorded there, open a detailed issue
with all steps and pertinent information about your cluster setup.

If you wish to contact us directly, use the form located on the
[Contact]({{ site.baseurl }}/contact/) page.
