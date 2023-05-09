#!/bin/sh

set -e

git config --global --add safe.directory /github/workspace

git fetch --tags
# This suppress an error occurred when the repository is a complete one.
git fetch --prune --unshallow || true

latest_tag=''
sort_flag='--sort=-refname'

if [ "${INPUT_SORT_BY_DATE}" = 'true' ]; then
  # Set the 'sort' flag
  sort_flag='--sort=-creatordate'
fi

if [ "${INPUT_SEMVER_ONLY}" = 'false' ]; then
  # Get a actual latest tag.
  # If no tags found, supress an error. In such case stderr will be not stored in latest_tag variable so no additional logic is needed.
  latest_tag=$(git describe --abbrev=0 --tags || true)
else
  # Get a latest tag in the shape of semver.
  for ref in $(git for-each-ref --sort=-creatordate --format '%(refname)' refs/tags); do
    tag="${ref#refs/tags/}"
    if echo "${tag}" | grep -Eq '^v?([0-9]+)\.([0-9]+)\.([0-9]+)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+[0-9A-Za-z-]+)?$'; then
      latest_tag="${tag}"
      break
    fi
  done
fi

# Get a latest tag
for ref in $(git for-each-ref ${sort_flag} --format '%(refname)' refs/tags); do
  tag="${ref#refs/tags/}"

  # Return if it is in semver format
  if echo "${tag}" | grep -Eq '^v?([0-9]+)\.([0-9]+)\.([0-9]+)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+[0-9A-Za-z-]+)?$'; then
    latest_tag="${tag}"
    break
  fi

  # Return if the user didn't ask for semver format
  if [ "${INPUT_SEMVER_ONLY}" = 'false' ]; then
    # Get a actual latest tag.
    latest_tag="${tag}"
    break
  fi
done

if [ "${latest_tag}" = '' ] && [ "${INPUT_WITH_INITIAL_VERSION}" = 'true' ]; then
  latest_tag="${INPUT_INITIAL_VERSION}"
fi

echo "::set-output name=tag::${latest_tag}"
