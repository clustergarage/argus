---
layout: doc
title: Examples
subtitle: Test Argus with some example deployments
tags: examples
---

#### Topics
{:.no_toc}
* TOC
{:toc}

## Kubernetes

### Guestbook Example

```shell
kubectl apply -f \
  https://raw.githubusercontent.com/kubernetes/kubernetes/release-1.10/examples/guestbook/all-in-one/guestbook-all-in-one.yaml
kubectl apply -f \
  https://raw.githubusercontent.com/clustergarage/argus/master/examples/guestbook-argus-watch.yaml
```

### NGiNX Example

```shell
kubectl run nginx --image=nginx
kubectl apply -f \
  https://raw.githubusercontent.com/clustergarage/argus/master/examples/nginx-argus-watch.yaml
```

## OpenShift

### Django Example

```shell
oc new-app python:3.5~https://github.com/openshift/django-ex
oc apply -f \
  https://raw.githubusercontent.com/clustergarage/argus/master/examples/djangoex-argus-watch.yaml
```

### Jenkins Sidecar Example

```shell
oc apply -f \
  https://raw.githubusercontent.com/clustergarage/argus/master/examples/sidecar/jenkins-sidecar.yaml
oc apply -f \
  https://raw.githubusercontent.com/clustergarage/argus/master/examples/sidecar/sidecar-argus-watch.yaml
```

