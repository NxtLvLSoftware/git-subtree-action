#!/bin/sh -l

set -e

# Key scan for github.com
ssh-keyscan github.com > /root/.ssh/known_hosts

# Set ssh key for subtree
echo "${INPUT_DEPLOY_KEY}" >> /root/.ssh/subtree
chmod 0600 /root/.ssh/subtree

# Get subtree repository into split directory
git clone subtree:"${INPUT_REPO}" .split --bare

# Create the subtree split branch
git subtree split --prefix="${INPUT_PATH}" --squash -b split
# Push to the subtree directory
git push ./.split split:master

PUSH_ARGS="-u"

# Check for force push to remote
if [ "$INPUT_FORCE" == "true" ]; then
	PUSH_ARGS="${PUSH_ARGS} -f"
fi

cd ./.split
git push "${PUSH_ARGS}" origin master

# Tag the subtree repository
if [ "$INPUT_TAG" != "false" ]; then
	if [ "$INPUT_TAG" == "true" ]; then
		INPUT_TAG="${GITHUB_REF}"
	fi

	git tag $(basename "${INPUT_TAG}")
	git push --tags
fi