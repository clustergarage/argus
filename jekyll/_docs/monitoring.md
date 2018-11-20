---
layout: doc
title: Monitoring Watches
subtitle: Set up monitoring and alerts of watchers
tags: monitoring arguswatcher
---

Once you have [ArgusWatchers]({{ site.baseurl }}/docs/arguswatcher/) defined,
you're ready to start monitoring for notify events; perhaps you'll even want to
set up alerts on high priority events. We provide out-of-the-box metrics
handling with [Prometheus](https://prometheus.io) so you'll be able to receive
time-series data that you can immediately monitor. Ultimately, it will be up to
you to use your logging framework of choice to monitor the way you're used to
doing.

## Prometheus

When running a master Prometheus server, to add the scraper that
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
# Argus metrics
# - arguswatcher
# - event
# - nodeName
argus_events_total{arguswatcher="mywatcher",...}

# gRPC metrics
# - grpc_method
# - grpc_service
# - grpc_type
grpc_client_handled_total{grpc_service="argus.Argusd"...}
grpc_client_msg_received_total{grpc_service="argus.Argusd"...}
grpc_client_msg_sent_total{grpc_service="argus.Argusd"...}
grpc_client_started_total{grpc_service="argus.Argusd"...}
```

The metric `argus_events_total` is what you'll be building your dashboards
from, as well as alerting on specific events as they occur. The gRPC-related
metrics are exposed to measure the performance between daemon and controller.

