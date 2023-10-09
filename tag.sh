#!/bin/bash

git fetch --tags

# Parse the major, minor, and patch versions from the tag
last_tag=$(git describe --tags $(git rev-list --tags --max-count=1))

# Parse the major, minor, patch, and rc versions from the tag
major=$(echo $last_tag | awk -F. '{if($1=="") print "0"; else print $1}')
minor=$(echo $last_tag | awk -F. '{if($2=="") print "0"; else print $2}')
patch=$(echo $last_tag | awk -F- '{split($1,a,"."); if(a[3]=="") print "0"; else print a[3]}')
rc=$(echo $last_tag | awk -F- '{if($2=="") print "0"; else print $2}')

# Determine the version component to increment (major, minor, patch, or rc)
if [ "$1" == "major" ]; then
    major=$((major + 1))
    minor=0
    patch=0
elif [ "$1" == "minor" ]; then
    minor=$((minor + 1))
    patch=0
elif [ "$1" == "patch" ]; then
    patch=$((patch + 1))
elif [ "$1" == "rc" ]; then
    # Increment the release candidate version
    rc=$((rc + 1))
    new_tag="$major.$minor.$patch-rc-$rc-$(git rev-parse --short HEAD)"
    echo "New release candidate tag: $new_tag"
else
    echo "Invalid parameter. Please specify 'major', 'minor', 'patch', or 'rc'."
    exit 1
fi

# Create the new version tag if it's not a release candidate
if [ "$1" != "rc" ]; then
    new_tag="$major.$minor.$patch"
    echo "New version tag: $new_tag"
fi

git tag -a -m $new_tag $new_tag
