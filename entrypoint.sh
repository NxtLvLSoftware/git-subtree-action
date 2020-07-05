#!/bin/sh -l

# Key scan for github.com
ssh-keyscan github.com > /root/.ssh/known_hosts

# Set ssh key for subtree
echo "${INPUT_DEPLOY_KEY}" >> /root/.ssh/subtree
chmod 0600 /root/.ssh/subtree

# Get subtree repository into split directory
git clone subtree:"${INPUT_REPO}" /tmp/split --bare

# Create the subtree split branch
git subtree split --prefix="${INPUT_PATH}" --squash -b split
# Push to the subtree directory
git push /tmp/split split:master

cd /tmp/split
git push -u origin master

# Tag the subtree repository
if [ "$INPUT_TAG" != "false" ]; then
	if [ "$INPUT_TAG" == "true" ]; then
		INPUT_TAG="${GITHUB_REF}"
	fi

	git tag $(basename "${INPUT_TAG}")
	git push --tags
fi