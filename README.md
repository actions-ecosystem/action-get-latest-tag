# Action Get Latest Tag

[![actions-workflow-lint][actions-workflow-lint-badge]][actions-workflow-lint]
[![release][release-badge]][release]
[![license][license-badge]][license]

This is a GitHub Action to get a latest Git tag.

It would be more useful to use this with other GitHub Actions' outputs.

## Inputs

|     NAME      |                                       DESCRIPTION                                       |  TYPE  | REQUIRED | DEFAULT |
| ------------- | --------------------------------------------------------------------------------------- | ------ | -------- | ------- |
| `semver_only` | Whether gets only a tag in the shape of semver. `'v'` prefix is accepted for tag names. | `bool` | `false`  | `false` |

If `inputs.semver_only` is `true`, the `outputs.tag` will be in the shape of semver.

This input is useful for versioning that binds a major version is the latest of that major version (e.g., `v1` == `v1.*`), like GitHub Actions.
In such a case, the actual latest tag is a major version, but the version isn't as we expected when we want to work with semver.

Let's say you did the following versioning.

```console
$ git tag v1.0.0 && git push origin v1.0.0
$ # some commits...
$ git tag v1.1.0 && git push origin v1.1.0
$ git tag v1 && git push origin v1 # bind v1 to v1.1.0.
```

In such a case, `outputs.tag` varies like this:

- `inputs.semver_only=false` -> `outputs.tag=v1`
- `inputs.semver_only=true` -> `outputs.tag=v1.1.0`

## Outputs

| NAME  |                      DESCRIPTION                      |   TYPE   |
| ----- | ----------------------------------------------------- | -------- |
| `tag` | The latest tag. If no tag exists, this value is `''`. | `string` |

## Example

```yaml
name: Push a new tag with Pull Request

on:
  pull_request:
    types: [closed]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - uses: actions-ecosystem/action-release-label@v1
        id: release-label
        if: ${{ github.event.pull_request.merged == true }}

      - uses: actions-ecosystem/action-get-latest-tag@v1
        id: get-latest-tag
        if: ${{ steps.release-label.outputs.level != null }}

      - uses: actions-ecosystem/action-bump-semver@v1
        id: bump-semver
        if: ${{ steps.release-label.outputs.level != null }}
        with:
          current_version: ${{ steps.get-latest-tag.outputs.tag }}
          level: ${{ steps.release-label.outputs.level }}

      - uses: actions-ecosystem/action-push-tag@v1
        if: ${{ steps.release-label.outputs.level != null }}
        with:
          tag: ${{ steps.bump-semver.outputs.new_version }}
          message: '${{ steps.bump-semver.outputs.new_version }}: PR #${{ github.event.pull_request.number }} ${{ github.event.pull_request.title }}'
```

For a further practical example, see [.github/workflows/release.yml](.github/workflows/release.yml).

## License

Copyright 2020 The Actions Ecosystem Authors.

Action Get Latest Tag is released under the [Apache License 2.0](./LICENSE).

<!-- badge links -->

[actions-workflow-lint]: https://github.com/actions-ecosystem/action-get-latest-tag/actions?query=workflow%3ALint
[actions-workflow-lint-badge]: https://img.shields.io/github/workflow/status/actions-ecosystem/action-get-latest-tag/Lint?label=Lint&style=for-the-badge&logo=github

[release]: https://github.com/actions-ecosystem/action-get-latest-tag/releases
[release-badge]: https://img.shields.io/github/v/release/actions-ecosystem/action-get-latest-tag?style=for-the-badge&logo=github

[license]: LICENSE
[license-badge]: https://img.shields.io/github/license/actions-ecosystem/action-add-labels?style=for-the-badge
