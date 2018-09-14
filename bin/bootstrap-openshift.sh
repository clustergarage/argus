#!/bin/sh

oc new-project fim
oc adm policy add-scc-to-user anyuid -n fim -z fim-admin
oc adm policy add-scc-to-user privileged -n fim -z fim-admin
oc apply -f configs/
