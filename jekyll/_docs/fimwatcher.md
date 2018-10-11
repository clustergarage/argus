---
layout: doc
title: Defining a FimWatcher
subtitle: Watch for important events on your deployments
tags: introduction fimwatcher
---

Once you have **fim-k8s** installed on your cluster, you are ready to start
setting up watchers for your deployments. All possible configurations of the
how, and what, of setting up a FimWatcher on your deployments are described
below.

#### Topics
{:.no_toc}
* TOC
{:toc}

## Required definition

At a bare minimum, the fields you need to provide are the `selector`, which
works just like any other label selector in Kubernetes; the `subjects` array
allows you to define any number of path/event combination to watch.

For example, you have an important path that should never receive any kind
of modification events. You can set a subject as the example below, in order
to receive any notification when a `modify` inode event happens at that path
location. This includes any change to the path itself, as well as children
inside the path.

```yaml
apiVersion: fimcontroller.clustergarage.io/v1alpha1
kind: FimWatcher
metadata:
  name: mywatcher
spec:
  selector:
    matchLabels:
      app: myapp
  subjects:
  - events:
    - modify
    paths:
    - /path/to/watch
```

#### List of all possible `events`

- `access` - file was accessed
- `attrib` - metadata changed; for example: permissions, timestamps, extended
  attributes, link count, user/group ID
- `closewrite` - file opened for writing was closed
- `closenowrite` - file or directory not opened for writing was closed
- `close` - includes `closewrite` and `closenowrite` events
- `create` - file or directory was created in watched directory
- `delete` - file or directory deleted from watched directory
- `deleteself` - watched file or directory was itself deleted
- `modify` - file was modified
- `moveself` - watched file or directory was itself moved
- `movedfrom` - generated for the directory containing the old filename when a
  file is renamed
- `movedto` - generated for the directory containing the new filename when a
  file is renamed
- `move` - includes `moveself`, `movedfrom`, and `movedto` events
- `open` - file or directory was opened
- `all` - includes all events listed above

## Recursively watching a directory

If you're familiar with `inotify` you'd know it only works on a specified path
and does not watch recursively. We added the ability to do so by passing a flag
in through the configuration; this will keep a tree of child nodes off the main
parent path that you pass into the subject `paths`. We make sure to handle any
possible new addition, deletion or update of a child path, even if the parent
path is modified, deleted, unmounted, from under us.

```yaml
  subjects:
  - events:
    - modify
    paths:
    - /path/to/watch
    recursive: true
```

## Recursively watching a directory with a maximum depth

In addition to watching recursively, if you only wish to recursively watch at
a certain number of children below the parent, you can specify a `maxDepth`
amount in the configuration. After that depth is reached it will stop at that
leaf level and not go any further.

```yaml
  subjects:
  - events:
    - modify
    paths:
    - /path/to/watch
    recursive: true
    maxDepth: 2
```

## Ignoring specific paths

Also in addition to the recursive watch option, if there are specific paths you
wish to ignore, such as a cache folder, a SCM folder like `.git`, or other
logical cases, an `ignore` array similar to the `paths` array can be provided.

```yaml
  subjects:
  - events:
    - modify
    paths:
    - /path/to/watch
    ignore:
    - .cache
    recursive: true
```

## Watching only directories

An extra flag can be provided to `inotify` that ensures the watched path is
specifically a directory type. In the case of modifying that path into a file
or symlink, it provides a race-free way of ensuring that you are always
monitoring it as a directory.

In the case of the example below, it would attempt to watch `file.ext` as a
directory; if this is not an actual directory it will ignore it from any
listeners and will not receive any updates on that file.

```yaml
  subjects:
  - events:
    - modify
    paths:
    - /path/to/watch
    - /file.ext
    onlyDir: true
```

## Custom logging format

If you want to specify your own logging format when a watcher is notified of an
update, you can do so with the `logFormat` option. This takes a format string
with specifiers that we will later interpolate with real values.

```yaml
apiVersion: fimcontroller.clustergarage.io/v1alpha1
kind: FimWatcher
metadata:
  name: mywatcher
spec:
  selector:
    matchLabels:
      app: myapp
  logFormat: "event = {event}; path = {path}; file = {file}"
  subjects:
  - events:
    - modify
    paths:
    - /path/to/watch
```

The default log format is `{event} {ftype} '{path}{sep}{file}' ({pod}:{node})`.

> Example output using the default format:
`MODIFY file '/path/to/file.ext' (foo-1-pod:barnode)`

#### List of all possible `logFormat` specifiers

- `pod` - name of the pod
- `node` - name of the node
- `event` - inotify event that was observed
- `path` - name of the directory path
- `file` - name of the file
- `ftype` - evaluates to "file" or "directory"
- `sep` - placeholder for a "/" character to include (e.g. between the
`path`/`file` specifiers)

