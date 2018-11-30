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

Whether you're running a vanilla Kubernetes cluster with minikube, or in a
cloud-provided one such as GKE, we provide a set of examples to test out
Argus located in the [examples/
folder](https://github.com/clustergarage/argus/tree/master/examples) of the
GitHub repo.

### NGiNX Example

```shell
kubectl run nginx --image=nginx
kubectl apply -f \
  https://raw.githubusercontent.com/clustergarage/argus/master/examples/nginx-argus-watch.yaml
```

This is a basic example of monitoring two different paths for a single event.
The watcher spec has a single subject that watches:

```yaml
paths:
- /etc/nginx
- /etc/init.d/nginx
events:
- modify
```

If you were to change any of the files under `/etc/nginx` it would notify on
that `modify` message.

You could also edit this watcher and update the `paths` to include
`/var/log/nginx`. This should update the watcher, that you can then exec into
the container to generate some messages:

```shell
$ kubectl exec -it <nginx-pod-name> -- /bin/bash

root@<nginx-pod-name>:/# echo "test" >> /var/log/nginx/foo.log
```

This will create a new log file and generate a `MODIFY` event that will show up
in the `argusd` logs:

```shell
$ kubectl logs <argusd-pod-name>

MODIFY file '/var/log/nginx/foo.log' (<nginx-pod-name>:<node-name>)
```

Another interesting test to try is to edit the [ArgusWatcher
definition]({{site.baseurl}}/docs/arguswatcher/#recursively-watching-a-directory)
with `recursive: true` on the subject to receive all events that happen under
subdirectories of the specified paths as well. For example, editing the
`/etc/nginx/conf.d/default.conf` once it is watching recursively would report
messages when it previously would have not.

### Guestbook Example

```shell
kubectl apply -f \
  https://raw.githubusercontent.com/kubernetes/kubernetes/release-1.10/examples/guestbook/all-in-one/guestbook-all-in-one.yaml
kubectl apply -f \
  https://raw.githubusercontent.com/clustergarage/argus/master/examples/guestbook-argus-watch.yaml
```

The "Hello World" of Kubernetes deployments can be monitored fairly easily.
Since this creates both a backend and frontend deployment with differing
labels, we'll need to create two watchers as well.

The frontend matches on labels: `app=guestbook,tier=frontend` with a subject:

```yaml
paths:
- /var/www/html
events:
- modify
```

The backend matches on labels: `app=redis,tier=backend` with a subject:

```yaml
paths:
- /data
events:
- create
- modify
```

The Redis app that runs in this backend container will create and modify
various data objects as it goes. We can see these being monitored as they
happen as a simple test.

## OpenShift

With an OpenShift cluster, we provide some slightly different examples, though
the watcher definition is completely environment-agnostic. These are also
located under the [examples/
folder](https://github.com/clustergarage/argus/tree/master/examples) of the
GitHub repo.

### Django Example

```shell
oc new-app python:3.5~https://github.com/openshift/django-ex
oc apply -f \
  https://raw.githubusercontent.com/clustergarage/argus/master/examples/djangoex-argus-watch.yaml
```

Another basic example, for OpenShift specifically, to test the same kind of
watchers you would be doing above in regular Kubernetes environments, simply
watching a path for multiple events:

```yaml
paths:
- /opt/app-root
events:
- create
- modify
```

### Jenkins Sidecar Example (Advanced)

```shell
oc apply -f \
  https://raw.githubusercontent.com/clustergarage/argus/master/examples/sidecar/jenkins-sidecar.yaml
oc apply -f \
  https://raw.githubusercontent.com/clustergarage/argus/master/examples/sidecar/sidecar-argus-watch.yaml
```

This advanced example combines a Jenkins deployment with an NGiNX sidecar, so
multiple containers are running in a single pod. This will allow us to still
define our watchers the same way, which will attempt to monitor specified paths
in each of the containers. If that container does not have that path, e.g.
Jenkins' container will not have an `/etc/nginx` path to watch, so it will
ignore it.

In addition to multiple containers running in this pod, we set up multiple
subjects, one dealing with `modify` events on files/folders we would not want
to see any changes happen to (such as password and secrets files):

```yaml
paths:
- /var/lib/jenkins/password
- /var/lib/jenkins/secret.key
- /var/lib/jenkins/secrets
- /etc/nginx
events:
- modify
```

The other subject will recursively watch a well-known Jenkins directory for
`open` events, ignoring a set of paths we wouldn't care to monitor, and tacking
on a custom tag on each message (`foo=bar`).

```yaml
paths:
- /var/lib/jenkins
ignore:
- .groovy
- .java
- .pki
- plugins
- war
events:
- open
recursive: true
tags:
  foo: bar
```

Messages generated with this custom tag will look similar to this:

```shell
$ oc logs <argusd-pod-name>

OPEN file '/var/lib/jenkins/<subdir>/<file>' (<jenkins-pod-name>:<node-name>) foo=bar
```
