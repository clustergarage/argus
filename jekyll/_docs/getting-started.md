---
layout: doc
title: Getting Started
subtitle: Installing Argus in your Kubernetes cluster
tags: introduction arguswatcher
---

**Argus** works by configuring a custom Kubernetes resource that defines
paths and events that you want to be notified about for your current
deployments. This custom resource, in conjunction with a cluster controller
running and listening for lifecycle events, is responsible for maintaining a
source of truth between the state of the cluster and the daemons listening for
filesystem events on each node.

#### Topics
{:.no_toc}
* TOC
{:toc}

## Prerequisites

In order to properly run these components, a Kubernetes cluster running
**v1.9** or above is required. Depending on your environment, there may be
additional requirements to run both the daemon with Linux capabilities and the
controller with an appropriate level of access to receive cluster events.

Since procfs `/proc/[pid]` subdirectories are owned by the effective user and
group of the process, we require escalated privileges so the daemon can watch
for filesystem events of any process running in your cluster, directly on the
host.

If running in a multi-tenant environment, you certainly will **not** be able to
have the kind of escalated privileges needed to gain access to the host
filesystem, for obvious reasons.

## Quickstart

We provide multiple paths of configuration for both vanilla Kubernetes and
OpenShift, which has additional security measures in place.

{% codetabs %}
{% codetab Kubernetes %}
To deploy **Argus** on a vanilla Kubernetes environment, simply run an
`apply` on the following hosted configuration:

```shell
kubectl apply -f \
  https://raw.githubusercontent.com/clustergarage/argus/master/configs/argus-k8s.yaml
```

This will create a `Namespace` **argus** under which all the components will be
organized.
{% endcodetab %}
{% codetab OpenShift %}
OpenShift has a more opinionated security model by default. We assume a normal
OpenShift install, which requires a few more components to be created. This can
be done with the following command:

```shell
oc apply -f \
  https://raw.githubusercontent.com/clustergarage/argus/master/configs/argus-openshift.yaml
```

This will create an OpenShift `Project` **argus** under which all components
will be organized. In addition to creating a `Namespace`, an OpenShift project
needs various `RoleBindings` for building and pulling images via an
`ImageStream` and for our `ServiceAccount` to have an admin role reference.
OpenShift also requires `SecurityContextConstraints` to properly run containers
as certain users, with Linux capabilities, and gain access to the host PID
namespace and volume.
{% endcodetab %}
{% codetab Helm %}
To install using a Helm chart, we provide a couple ways to do this. The
simplest being an archive file included in each release:

```shell
helm install \
  https://github.com/clustergarage/argus/releases/download/v0.4.0/argus-0.4.0.tgz
```

The other way is to add a Helm repository to your cluster and update/install
using these mechanisms:

```shell
helm repo add clustergarage \
  https://raw.githubusercontent.com/clustergarage/argus/master/helm/
helm repo update
helm install clustergarage/argus
```

This will create a `Namespace` **argus** under which all the components will be
organized.
{% endcodetab %}
{% endcodetabs %}

Under the **argus** namespace is a `ServiceAccount` used to run all items of
**Argus**; this service account will also get a `ClusterRoleBinding` with
settings that allow the controller and daemon to be run with their required
privileges.

A `CustomResourceDefinition` is included to define a custom **ArgusWatcher**
type housing the pod selector, paths, events, and optional flags for the
watcher.

Finally, the **arguscontroller** `Deployment` and **argusd** `DaemonSet` are
the core of the product. There is a headless `Service` used to communicate
between the controller and all instances of the daemons.

> You can verify that it installed properly by inspecting `kubectl -n argus get
all`

All pods should eventually converge into `Running` state. The daemon pods in
particular should be running on each node that run workloads you wish to be
notified on. The controller is suggested to run with a single replica, as all
method calls to the daemon are idempotent; it can still function properly with
\>1 replicas, however.

## Secure Communication

To secure the gRPC communication between controller and daemon, we provide
secure variations of each configurations described above.

You must provide **your own** certificates, which won't be described in this
documentation. The daemon will be spun up with a certificate/private key pair
and an optional CA certificate as the gRPC server(s); the controller will act
as a client so has additional TLS flags that can be passed in.

{% codetabs %}
{% codetab Kubernetes %}
With your SSL certificates, create a **ConfigMap** with keys as demonstrated in
the [examples/ folder](https://raw.githubusercontent.com/clustergarage/argus/master/examples/argus-config.yaml).
This includes a `ca.pem` for root CA certificate, `cert.pem` and `key.pem` for
certificate/private keys. Apply the **ConfigMap** and the secure variation of
the configuration files.

```shell
kubectl apply -f \
  https://raw.githubusercontent.com/clustergarage/argus/master/configs/argus-k8s-secure.yaml
# add your keys to a ConfigMap
kubectl apply -f argus-config.yaml
```
{% endcodetab %}
{% codetab OpenShift %}
With your SSL certificates, create a **ConfigMap** with keys as demonstrated in
the [examples/ folder](https://raw.githubusercontent.com/clustergarage/argus/master/examples/argus-config.yaml).
This includes a `ca.pem` for root CA certificate, `cert.pem` and `key.pem` for
certificate/private keys. Apply the **ConfigMap** and the secure variation of
the configuration files.

```shell
oc apply -f \
  https://raw.githubusercontent.com/clustergarage/argus/master/configs/argus-openshift-secure.yaml
# add your keys to a ConfigMap
oc apply -f argus-config.yaml
```
{% endcodetab %}
{% codetab Helm %}
There are various limitations with Helm and providing SSL certs outside the
provided chart; in particular, any files that are read need to be included
inside the chart directory itself. Until this feature is added to Helm, we have
to do some hacky bits first.

```shell
# download clustergarage/argus helm chart locally
cp -r /path/to/ssl/certs /path/to/argus/
helm install ./argus --set tls=true
```
{% endcodetab %}
{% endcodetabs %}

## Limitations and Caveats

`argusd` should be scheduled out on all nodes that can handle compute that you
would want to monitor. If your nodes have any
[taints](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/),
then there will need to be an explicit tolerance set on the **DaemonSet** in
order for these pods to be run on them. It will be up to you to add the
appropriate tolerance to the configuration.

Certain images (such as the official **nginx**) will symlink to special devices
such as `/var/log/nginx/access.log -> /dev/stdout`. These devices are streams
which are symlinks to pseudo-terminals on the system and are not files that can
be monitored by `inotify`. For the same reason, they are also not candidates for
the practice of file integrity monitoring.

## Need Help?

If you have any issues with any of the steps to get started with running this
in your cluster, please begin by checking to see if any of the issues you may
be facing are included in our
[GitHub issues](https://github.com/clustergarage/argus/issues). If you
suspect you may be having problems not recorded there, open a detailed issue
with all steps and pertinent information about your cluster setup.

If you wish to contact us directly, use the form located on the
[Contact]({{site.baseurl}}/contact/) page.
