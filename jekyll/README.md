# fim-k8s Documentation

## Prerequisites

- Ruby
- Bundler (`gem install bundler`)

## Serve Locally

```
bundle
bundle exec jekyll serve --livereload
# navigate to localhost:4000
```

## Build

Since we use a custom plugin that GitHub pages (in `--safe` mode) does not
allow by default, we must build it manually.

```
bundle exec jekyll build -d ../docs
```

This will build it into the repo's /docs folder which GitHub pages hosts from
the master branch.
