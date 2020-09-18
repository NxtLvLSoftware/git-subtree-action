# git-subtree-action
The source for the git-subtree github action.

## About
This repository contains the source code for the git-subtree action that allows you to easily keep a git subtree in sync
using the actions pipeline.

## Usage

### Action Inputs
| Input        | Description                                                                                                                         |
| ------------ | -------------------------------------------------------------------------------------                                               |
| repo         | Child repository to sync the subtree to (eg. owner/repository.)                                                                     |
| path         | Path prefix in parent repo to split into child subtree (eg. src/PackageName.)                                                       |
| deploy_key   | Deployment SSH key for pushing to child repo (checkout out deployment tokens for single repos or bot accounts for multi-repos/orgs.)|
| tag          | Create a tag on the child subtree repository (tag name is the supplied value.)                                                      |
| force        | Force push to the child subtree repository (recommended for pure downstream mirrors.)                                               |


### Workflow Examples
This example uses a matrix to sync a list of namespaces into child subtree repos.

```yaml
name: ci

on: [push]

jobs:
  sync-downstream:

    runs-on: ubuntu-latest

    strategy:
      fail-fast: false
      matrix:
        path:
          - command
          - database
          - support
          - thread
          - warp

    name: Update downstream ${{ matrix.path }} package

    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - uses: nxtlvlsoftware/git-subtree-action@master
        with:
          repo: 'nxtlvlsoftware-packages/pmmp-${{ matrix.path }}'
          path: 'src/${{ matrix.path }}'
          deploy_key: ${{ secrets.DOWNSTREAM_GITHUB_DEPLOY_KEY }}
          force: true
```

### Syncing tags
You can also keep tags/releases in sync by using the `tag` input option.

```yaml
name: ci

on:
  release:
    types: [published]

jobs:
  sync-downstream:

    runs-on: ubuntu-latest

    strategy:
      fail-fast: false
      matrix:
        path:
          - area
          - command
          - database

    name: Update downstream ${{ matrix.path }} package

    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - uses: nxtlvlsoftware/git-subtree-action@master
        with:
          repo: 'nxtlvlsoftware-packages/pmmp-${{ matrix.path }}'
          path: 'src/${{ matrix.path }}'
          deploy_key: ${{ secrets.DOWNSTREAM_GITHUB_DEPLOY_KEY }}
          tag: true # will use the tag name from the event if true is specified
```