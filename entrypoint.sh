#!/bin/sh -l

set -e

# Key scan for github.com
ssh-keyscan github.com > /root/.ssh/known_hosts

# Set ssh key for subtree
echo "${INPUT_DEPLOY_KEY}" >> /root/.ssh/subtree
chmod 0600 /root/.ssh/subtree

# Generate sha256 of the downstream repo name
SPLIT_DIR=$(echo -n "${INPUT_REPO}" | sha256sum)
SPLIT_DIR="${SPLIT_DIR::-3}"

# Get subtree repository into split directory
git clone subtree:"${INPUT_REPO}" "${SPLIT_DIR}" --bare

# Create the subtree split branch
git subtree split --prefix="${INPUT_PATH}" -b split

# Check for force push to remote
if [ "$INPUT_FORCE" == "true" ]; then
	PUSH_ARGS="-f"
fi

# Push to the subtree directory
git push "${PUSH_ARGS}" "${SPLIT_DIR}" split:master

cd "${SPLIT_DIR}"
git push -u "${PUSH_ARGS}" origin master

# Tag the subtree repository
if [ "$INPUT_TAG" != "false" ]; then
	if [ "$INPUT_TAG" == "true" ]; then
		INPUT_TAG="${GITHUB_REF}"
	fi

	git tag $(basename "${INPUT_TAG}")
	git push --tags
fi