---
layout: doc
title: Getting Started
subtitle: File Integrity Monitoring for Kubernetes
tags: introduction fimwatcher
---

**fim-k8s** works by configuring a custom Kubernetes resource that defines which
pods should be notified of certain events at the filesystem-level. This custom
resource, in conjunction with a Kubernetes controller that runs in your cluster,
listens for certain cluster events and is responsible for syncing between the
state of the cluster pods and daemons running on every node in the cluster.

## Quickstart

First, a Kubernetes cluster running v1.8 or above is required. Depending on the
environment where you wish to run **fim-k8s**, there may be additional
requirements to run the daemon as a privileged container, and for the controller
to have an appropriate level of access to receive cluster events.

We provide multiple paths of configuration for both vanilla Kubernetes and
OpenShift, which has additional security measurements in place.  

{% codetabs %}

{% codetab Kubernetes %}
To deploy **fim-k8s** on a vanilla Kubernetes environment, simply run an `apply`
on the following:

```shell
kubectl apply -f \
  https://raw.githubusercontent.com/clustergarage/fim-k8s/master/configs/fim-k8s.yaml
```

This will create a **Namespace** `fim` under which all the components will be
housed. The two main components you will be monitoring and logging are the
`fimcontroller` Deployment and `fimd` DaemonSet.
{% endcodetab %}

{% codetab OpenShift %}
OpenShift has a more opinionated security model by default. We assume a normal OpenShift
install, which requires a few more components to be created. This can be
done with the following command:

```shell
oc apply -f \
  https://raw.githubusercontent.com/clustergarage/fim-k8s/master/configs/fim-openshift.yaml
```

This will create an OpenShift **Project** `fim` under which all components will be
housed. The two main components you will be monitoring and logging are the
`fimcontroller` DeploymentConfig and `fimd` DaemonSet.
{% endcodetab %}

{% codetab Helm %}
To install using a Helm chart, we provide a couple ways to do this. The simplest
being an archive file included in each release:

```shell
helm install \
  https://github.com/clustergarage/fim-k8s/releases/download/v0.1.0/fim-k8s-0.1.0.tgz
```

The other way is to add a Helm repository to your cluster and
update/install using these mechanisms:

```shell
helm repo add clustergarage \
  https://raw.githubusercontent.com/clustergarage/fim-k8s/master/helm/
helm repo update
helm install clustergarage/fim-k8s
```

Lorem ipsum dolor sit amet.
{% endcodetab %}

{% endcodetabs %}

---

## Need Help?

Vestibulum eu tristique dui. Morbi convallis fringilla sapien non congue.
Suspendisse a gravida ex.

