# Contributing to Chaldea

## Developing

### Flutter Version

Make sure your flutter version is compatible with the version used in production. Check the deploy workflow for [web](./.github/workflows/deploy-web.yml) and [Github Release](./.github/workflows/deploy-github-release.yml).

### Formatting

```sh
sh ./scripts/format.sh
```

It will sort imports and format dart codes. `line-length` is set to 120. You might need to configure your IDE with proper settings.

Comments on imports may be messed up because of sorting imports.

### Update Json Models

```sh
sh ./scripts/build_runner.sh
```

Mainly for `JsonSerializable`, build config can be found at [build.yaml](./build.yaml).


## Code Style

### Avoid using `var` and `dynamic`

- [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo#avoid-using-var-and-dynamic)

Specified type or `final` is preferred.
