---
layout: doc
title: Monitoring Watches
subtitle: Set up monitoring and alerts of watchers
tags: monitoring arguswatcher
---

Once you have [ArgusWatchers]({{ site.baseurl }}/docs/arguswatcher/) defined,
you're ready to start monitoring for notify events; perhaps you'll even want to
set up alerts on high priority events. There are generic logfiles included in
both apps, and we provide out-of-the-box metrics handling with
[Prometheus](https://prometheus.io) so you'll be able to receive time-series
data that you can immediately monitor. Ultimately, it will be up to you to use
your logging framework of choice to monitor the way you're used to doing.

#### Topics
{:.no_toc}
* TOC
{:toc}

## Logfiles

Using the `glog` logging framework that most Kubernetes-related projects also
leverage, you can locate logfiles in both **argusd** and **arguscontroller**
containers at `/tmp/argusd.INFO` and `/tmp/arguscontroller.INFO`. The
**argusd** logs will show actual `inotify` events that were reported as they
happened, where **arguscontroller** log will only include Kubernetes
controller-related log messages such as receiving new watchers, connecting the
controller to daemons via gRPC, and pods being created, deleted, and updated
that a watcher cares about.

## Monitoring with Prometheus

When running a master Prometheus server, in order to add the scraper that
**arguscontroller** exposes, you will need to add the following definition to
your `prometheus.yml` config:

```yaml
scrape_configs:
  ...
  - job_name: 'argus'
    static_configs:
    - targets: ['argus-prometheus:2112']
```

After events are collected you will be able to see metrics streaming in around
a couple specifications:

```shell
# Argus metrics (labels = arguswatcher, event, nodeName)
argus_events_total{arguswatcher="mywatcher",...}

# gRPC metrics (labels = grpc_method, grpc_service, grpc_type)
grpc_client_handled_total{grpc_service="argus.Argusd"...}
grpc_client_msg_received_total{grpc_service="argus.Argusd"...}
grpc_client_msg_sent_total{grpc_service="argus.Argusd"...}
grpc_client_started_total{grpc_service="argus.Argusd"...}
```

The metric `argus_events_total` is what you'll be using to build your dashboards
and alerting on priority events as they occur. The gRPC-related metrics are
exposed to measure the performance between daemon and controller.

### Alerting

If watching for changes on a critical section of your filesystem that should not
receive any kind of event, one could set up an alert with Prometheus and
[Alertmanager](https://prometheus.io/docs/alerting/alertmanager). This could be
accomplished using the `increase()` function, for example:

```yaml
alert: PageOnModify
expr: increase(argus_events_total{arguswatcher="mywatcher",event="modify"}[1m]) > 0
labels:
  severity: page
...
```

## Grafana Dashboards

With Prometheus as a data source in your Grafana deployment and once
Prometheus starts scraping the `argus-prometheus` endpoint as a scrape target,
you will be able to start using these collected metrics to build dashboards in
Grafana.

We will provide some ready-to-go templates for Argus dashboards at a later
time...
