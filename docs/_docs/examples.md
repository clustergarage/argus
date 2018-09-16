---
layout: doc
title: Examples and Best Practices
subtitle: File Integrity Monitoring for Kubernetes
tags: foo bar baz
---

Lorem ipsum dolor sit amet, consectetur adipiscing elit.

Vestibulum quis nibh et nibh facilisis imperdiet. Aliquam faucibus vulputate lorem eu tincidunt.

#### Topics
{:.no_toc}
* TOC
{:toc}

## Kubernetes &mdash; NGiNX Example

Lorem ipsum dolor sit amet, consectetur adipiscing elit.

```shell
kubectl run nginx --image=nginx
kubectl apply -f
https://raw.githubusercontent.com/clustergarage/fim-k8s/master/examples/nginx-fim-watch.yaml
```

## OpenShift &mdash; Django Example

Lorem ipsum dolor sit amet, consectetur adipiscing elit.

```shell
oc new-app python:3.5~https://github.com/openshift/django-ex
oc apply -f https://raw.githubusercontent.com/clustergarage/fim-k8s/master/examples/djangoex-fim-watch.yaml
```

## OpenShift &mdash; Jenkins Sidecar Example

Lorem ipsum dolor sit amet, consectetur adipiscing elit.

```shell
oc apply -f
https://raw.githubusercontent.com/clustergarage/fim-k8s/master/examples/sidecar/jenkins-sidecar.yaml
oc apply -f
https://raw.githubusercontent.com/clustergarage/fim-k8s/master/examples/sidecar/sidecar-fim-watch.yaml
```

