#!/bin/sh

set -e

git fetch --tags
git fetch --prune --unshallow

latest_tag=''

if [ "${INPUT_SEMVER_ONLY}" = 'false' ]; then
    # Get a actual latest tag.
    latest_tag=$(git describe --abbrev=0 --tags)
else
    # Get a latest tag in the shape of semver.
    for tag in $(git tag | sort -r); do
        if echo "${tag}" | grep -Eq '^v?([0-9]+)\.([0-9]+)\.([0-9]+)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+[0-9A-Za-z-]+)?$'; then
            latest_tag="${tag}"
            break
        fi
    done
fi

if [ "${latest_tag}" = '' ] && [ "${INPUT_WITH_INITIAL_VERSION}" = 'true' ]; then
    latest_tag="${INPUT_INITIAL_VERSION}"
fi

echo "::set-output name=tag::${latest_tag}"
