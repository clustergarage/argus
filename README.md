# fim-k8s

## Running

#### Kubernetes

```
kubectl apply -f configs/
```

#### OpenShift

```
# add scc to run fimcontroller deployment
oc adm policy add-scc-to-user anyuid -n kube-system -z fim-admin
# add scc to run fimd daemonset
oc adm policy add-scc-to-user privileged -n kube-system -z fim-admin

oc apply -R -f configs/
```

## Defining a FimWatcher component

```
apiVersion: fimcontroller.clustergarage.io/v1alpha1
kind: FimWatcher
metadata: [...]
spec:
  selector:
    matchLabels:
      run: myapp
  subjects:
  - paths:
    - /var/log/myapp
    events:
    - open
    - modify
  - paths:
    - /var/log/financialdata
    events:
    - all
```

## Examples

#### NGiNX example (Kubernetes)

```
kubectl run nginx --image=nginx
kubectl apply -f examples/nginx-fim-watch.yaml
```

#### Django example (OpenShift)

```
oc new-app python:3.5~https://github.com/openshift/django-ex
oc apply -f examples/djangoex-fim-watch.yaml
```

##### Testing/Debugging

```
# tail logs of controller/daemon
oc logs -f -n kube-system fimcontroller.clustergarage.io-[...]
oc logs -f -n kube-system fimd.clustergarage.io-[...]

# scale deployment up/down to see watchers get started/stopped
oc edit dc django-ex

# generate create/modify message
oc rsh django-ex-[...]
echo "test" >> /opt/app-root/test.log

# example output:
Starting inotify watcher...
IN_CREATE: /proc/12345/root/opt/app-root/test.log [file]
IN_MODIFY: /proc/12345/root/opt/app-root/test.log [file]
```

#### Sidecar example (OpenShift)

```
oc apply -f examples/sidecar/
```
