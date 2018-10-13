# fim-k8s

This repository fronts the **fim-k8s** application suite. It includes several
components that make up the documentation, configuration files linked in the
docs, and a set of common examples to get you started.

**tl;dr--** [get started
here](https://clustergarage.io/fim-k8s/docs/getting-started/)!

## Purpose

The documentation files that build the [marketing
site](https://clustergarage.io/fim-k8s/) are hosted and maintained here.
Configuration files are hosted in order to be linked as raw YAML that can be
`apply`ed to your running cluster. In addition to those, a suite of common
examples that allow you to familiarize yourself with how to set up watchers on
common applications in both vanilla Kubernetes as well as OpenShift variants.

## Configuration Files

Located under:
- `configs/fim-k8s.yaml` &mdash; for vanilla Kubernetes clusters
- `configs/fim-openshift.yaml` &mdash; for OpenShift clusters

Presents the production configuration files to stand it up in your running
cluster; the steps to use these are summarized in the [getting
started](https://clustergarage.io/fim-k8s/docs/getting-started/) section of the
documentation.

## Running Examples

Located under:
- `examples/*`

Provides sample configurations to create and monitor FimWatchers with various
applications that will be outlined in the [examples and best
practices](https://clustergarage.io/fim-k8s/docs/examples/) documentation.

## Helm Repository

If using the popular Kubernetes package manager Helm, we maintain and host a
Helm repository in this area as well.

Located under:
- `helm/*`

Further information on how to use the Helm variation of **fim-k8s** is also
located in the [getting
started](https://clustergarage.io/fim-k8s/docs/getting-started/) section of the
documentation.

