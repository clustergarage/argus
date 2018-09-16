---
layout: doc
title: Quickstart
subtitle: File Integrity Monitoring for Kubernetes
tags: foo bar baz
---

Depending on your environment where you wish to run `fim-k8s`, there may be
additional requirements to run the daemon as a privileged container, and the
controller to see certain events happening on your cluster.

We provide two main paths of configuration for both vanilla Kubernetes and
OpenShift, which has additional security measures in place. Under each section the
components that will be deployed will be outlined.

## Kubernetes

To deploy `fim-k8s` on a vanilla Kubernetes environment, simply run an `apply`
on the following:

```shell
kubectl apply -f
https://raw.githubusercontent.com/clustergarage/fim-k8s/master/configs/fim-k8s.yaml
```

This will create a **Namespace** `fim` under which all the components will be
housed. The two main components you will be monitoring and logging are the
`fimcontroller` Deployment and `fimd` DaemonSet.

## OpenShift

OpenShift is much more security-minded by default. We assume a normal OpenShift
install, which requires a few more components to be created. This can be
done with the following command:

```shell
oc apply -f
https://raw.githubusercontent.com/clustergarage/fim-k8s/master/configs/fim-openshift.yaml
```

This will create an OpenShift **Project** `fim` under which all components will be
housed. The two main components you will be monitoring and logging are the
`fimcontroller` DeploymentConfig and `fimd` DaemonSet.

## Need Help?

Vestibulum eu tristique dui. Morbi convallis fringilla sapien non congue.  Suspendisse a gravida ex.

