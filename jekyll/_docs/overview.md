---
layout: doc
title: Overview
subtitle: File Integrity Monitoring for Kubernetes
redirect_from: /docs
tags: introduction
---

**fim-k8s** is a set of custom Kubernetes resources that facilitates filesystem
event monitoring on specified paths. It provides a rich set of configurations
to run alongside your existing Kubernetes deployments to make it easy to denote
audit-ready file integrity monitoring.

In deploying **fim-k8s** into your cluster, a couple of components will be
initialized. First, the controller listens directly for Kubernetes events and
is responsible for syncing cluster state with the daemons running on each node
to make sure specified pods that need to be watched, are. Second, the daemon is
run on each node to ensure that it can monitor running pods on the same node.
It is charged with setting up inode watchers via `inotify` to allow you to see
when certain filesystem events happen on the desired paths inside the pod.

It will be up to you to log, monitor, and track in your favorite tools of choice
these events that will be printed out. We will provide some patterns to do so on
popular sets of tools further in this documentation.

## Architecture

{% mermaid %}
graph RL
    A(procfs) -->|inotify| B[fimnotify]
    subgraph daemon
    C{fimd} --> B
    B .->|mqueue| C
    end
    D[fim-controller] ==>|gRPC| C
    C .-> D
    subgraph controller
    E(K8s listers<br />K8s informers) --> D
    F(FimWatcher CRDs) --> D
    end
{% endmermaid %}

### Custom Resource Definition

In order to describe the set of pods you want to create a watcher for, what
paths you are interested in monitoring, and for what events, you'll soon find
yourself creating a **FimWatcher** `CustomResourceDefinition`. That is, a
Kubernetes custom type that will be configured in your cluster, that gives a
specification to define a watcher type with all the fields and flags the
controller will understand, configure, and pass along to the daemon so it can
watch appropriately in the fashion you describe.

### Controller

`fimcontroller` is the glue between the Kubernetes lifecycle and the daemons 
listening for events on the filesystems. It responds to events such as pod
listers add, update, and delete, making sure that the proper state of the
daemon that is running on the same node as that pod has the watcher either
started or not on that daemon.

This controller operates in an idempotent fashion, in such cases that the
controller pod running is terminated and a new one spins up, it immediately
receives all the events upon startup that it would have received anyway over
time; this way we can reconstruct the proper state immediately. When a daemon
is not gracefully terminated, upon startup of a new daemon pod, we reconcile
that pod's current state (nothing) with what we expect it should be, and
all addition calls should be immediately fired; same as the previous case but
in reverse.

The other set of types the controller listens for is the **FimWatcher**
`CustomResourceDefinition` described above. This is the definition that you
will create to define what selector, paths, events, and lots of optional
flags to create the notion of a file integrity monitor watcher.


### Daemon

The **fimd** daemon will be deployed on all cluster nodes via a `DaemonSet`.
It starts a gRPC server to communicate back-and-forth with the controller,
described above. When it receives a message from the controller to create a
watcher, it takes the desired configuration and spawns a **fimnotify** process
with a custom set of rules. For example, if one wishes to watch the path
recursively, this can be configured with an optional flag and will maintain
a tree of additional paths to watch under the parent.

{% mermaid %}
graph LR
    A(procfs) -->|inotify| B[fimnotify]
    C{fimd} --> B
    B .->|mqueue| C
{% endmermaid %}

Once the **fimnotify** process receives an `inotify` message that the user
configured to watch for, it sends that message back to the **fimd** process
via a message queue and logs it in the cluster pod with any additional custom
logging configuration. This log can be picked up in the same way you'd watch
for logs in any other Kubernetes component.

Upon receiving an additional create message, if the watcher already exists, it
will handle it in an idempotent way, and simply update with the current
configuration. When receiving a delete message, if the watcher exists, it will
shut down the processes involved and remove this watcher from the daemon's
current state.

There is an additional state check called periodically by the controller that
reconciles what the daemon knows its state is with what the controller expects
the current state to be. Any additional creation and deletion methods may be
called due to any differences. This also allows for handling non-graceful
terminations of either daemon or controller pods, thus the proper state can
always be recreated in these cases.
