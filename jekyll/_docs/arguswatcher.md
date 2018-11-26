---
layout: doc
title: Defining an ArgusWatcher
subtitle: Watch for important events on your deployments
tags: introduction arguswatcher
---

Once you have **Argus** installed on your cluster, you are ready to start
setting up watchers for your deployments. All possible configurations of the
how, and what, of setting up an ArgusWatcher on your deployments are described
below.

#### Topics
{:.no_toc}
* TOC
{:toc}

## Required definition

At a bare minimum, the fields you need to provide are the `selector`, which
works just like any other label selector in Kubernetes. `matchLabels` and
`matchExpressions` are both supported, as described in the [labels and
selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels)
documentation. The `subjects` array allows you to define any number of path and
event combination to watch.

For example, you have an important path that should never receive any kind of
modification events. You can set a subject as the example below, in order to
receive any notification when a `modify` inode event happens at that path
location. This includes any change to the path itself, as well as children
inside the path.

```yaml
apiVersion: arguscontroller.clustergarage.io/v1alpha1
kind: ArgusWatcher
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

- `access` &mdash; file was accessed
- `attrib` &mdash; metadata changed; for example: permissions, timestamps,
  extended attributes, link count, user/group ID
- `closewrite` &mdash; file opened for writing was closed
- `closenowrite` &mdash; file or directory not opened for writing was closed
- `close` &mdash; includes `closewrite` and `closenowrite` events
- `create` &mdash; file or directory was created in watched directory
- `delete` &mdash; file or directory deleted from watched directory
- `deleteself` &mdash; watched file or directory was itself deleted
- `modify` &mdash; file was modified
- `moveself` &mdash; watched file or directory was itself moved
- `movedfrom` &mdash; generated for the directory containing the old filename
  when a file is renamed
- `movedto` &mdash; generated for the directory containing the new filename
  when a file is renamed
- `move` &mdash; includes `moveself`, `movedfrom`, and `movedto` events
- `open` &mdash; file or directory was opened
- `all` &mdash; includes all events listed above

#### Limitations

- If watching a directory that is symlinked, you will need to watch the
  **source** directory, not the destination. A symlink is a special kind of
  file and does not behave exactly like an actual directory. In the case of
  watching the destination, you would only receive events on that file but not
  on any events on any child objects under it.

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

In addition to the recursive watch option, if there are specific paths you wish
to ignore, such as a cache or SCM folder, an `ignore` array similar to `paths`
can be provided. Currently, these ignored paths are a simple direct comparison,
not a glob or regex check.

```yaml
  subjects:
  - events:
    - modify
    paths:
    - /path/to/watch
    ignore:
    - .cache
    - .git
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

## Custom tagging

Custom tags can be added per-subject to allow you to later query specific
portions of your watchers. These are defined in a YAML-style map and at logging
time will be condensed into a comma-separated list of `key=value` pairs. In the
case of the below example, when logging an event, the tags will should up as:
`foo=bar,lorem=ipsum` that you can later use your favorite logging aggregator
and query language to target this specific subject.

```yaml
apiVersion: arguscontroller.clustergarage.io/v1alpha1
kind: ArgusWatcher
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
    tags:
      foo: bar
      lorem: ipsum
```

## Custom logging format

If you want to specify your own logging format when a watcher is notified of an
update, you can do so with the `logFormat` option. This takes a format string
with specifiers that we will later interpolate with real values.

```yaml
apiVersion: arguscontroller.clustergarage.io/v1alpha1
kind: ArgusWatcher
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

The default log format is `{event} {ftype} '{path}{sep}{file}' ({pod}:{node}) {tags}`.

> Example output using the default format:
`MODIFY file '/path/to/file.ext' (foo-1-pod:barnode) foo=bar`

#### List of all possible `logFormat` specifiers

- `pod` &mdash; name of the pod
- `node` &mdash; name of the node
- `event` &mdash; inotify event that was observed
- `path` &mdash; name of the directory path
- `file` &mdash; name of the file
- `ftype` &mdash; evaluates to "file" or "directory"
- `tags` &mdash; list of custom tags in key=value comma-separated list
- `sep` &mdash; placeholder for a "/" character to include (e.g. between the
`path`/`file` specifiers)

