---
layout: doc
title: Defining a FimWatcher
subtitle: File Integrity Monitoring for Kubernetes
tags: foo bar baz
---

Lorem ipsum dolor sit amet, consectetur adipiscing elit.

Vestibulum quis nibh et nibh facilisis imperdiet. Aliquam faucibus vulputate lorem eu tincidunt.

#### Sections
{:.no_toc}
* TOC
{:toc}

## Required Definition

List all event types here. Nullam ultrices diam eget felis laoreet, ac pellentesque est dapibus.

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

List of possible `events`:
- `access` - file was accessed
- `modify` - file was modified
- `attrib` - metadata changed; for example: permissions, timestamps, extended
  attributes, link count, user/group ID
- `open` - file or directory was opened
- `close` - file opened-for-writing was closed; file or directory not
  opened-for-writing was closed
- `create` - file or directory was created in watched directory
- `delete` - file or directory deleted from watched directory; watched file or
  directory was itself deleted
- `move` - watched file or directory was itself moved; moved to/from events also
  included
- `all` - all events above

## Recursively Watching a Directory

Quisque et leo leo. Duis eleifend elit dolor, in malesuada mi eleifend vitae.

```yaml
  subjects:
  - events:
    - modify
    paths:
    - /path/to/watch
    recursive: true
```

## Recursively Watching a Directory with a Maximum Depth

Quisque et leo leo. Duis eleifend elit dolor, in malesuada mi eleifend vitae.

```yaml
  subjects:
  - events:
    - modify
    paths:
    - /path/to/watch
    recursive: true
    maxDepth: 2
```

## Ignoring Specific Paths

Duis mollis ex felis, eu pellentesque magna cursus eget.

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

## Watching Only Directories

Quisque et leo leo. Duis eleifend elit dolor, in malesuada mi eleifend vitae.

```yaml
  subjects:
  - events:
    - modify
    paths:
    - /path/to/watch
    - /file.ext
    onlyDir: true
```

Nulla quis magna erat. Etiam mollis sapien at erat tincidunt cursus. Pellentesque nisl urna, eleifend ut rutrum eu, tincidunt eget ex. Cras congue urna pulvinar risus blandit auctor. Nullam in feugiat odio.  Pellentesque lobortis justo id odio imperdiet vehicula. Proin ut purus at ex tempor auctor. Etiam vitae diam purus. Quisque ac orci metus. Vestibulum rhoncus felis vel fermentum tincidunt.

