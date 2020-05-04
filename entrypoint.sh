#!/bin/sh

set -e

git fetch --tags
git fetch --prune --unshallow

echo "::set-output name=tag::$(git describe --abbrev=0 --tags)"
