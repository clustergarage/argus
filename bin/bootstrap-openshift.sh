#!/bin/sh

oc adm policy add-scc-to-user anyuid -n kube-system -z fim-admin
oc adm policy add-scc-to-user privileged -n kube-system -z fim-admin
oc apply -R -f configs/
