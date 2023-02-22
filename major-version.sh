#!/bin/sh
#https://gist.github.com/danielestevez/2044589
#https://stackoverflow.com/questions/49252680
#https://superuser.com/questions/1749781
# BEFORE USING THIS SHELL, RUN `git add` AND `git commit`!
# This shell is designed to automatically push version tag and MAJOR version tag.
# Automatically detects if it is running under WSL. If so,
# Use `powershell.exe` to run `git push`, Otherwize, use `sh`.
# Usage: bash ./major-version.sh v1.0.0
set -e

if [ -z $1 ]; then # If not exist $1
    echo "Version tag not found!"
    echo "Usage: bash ./major-version.sh v1.0.0"
    exit 1
fi

echo "Auto push MAJOR version tag v1.0.0"
VERSION=$1
MAJOR=${VERSION%.*.*}
echo "Version: $VERSION"
echo "MAJOR version: $MAJOR"

if [ -z $WSL_DISTRO_NAME ]; then # If the environment WSL_DISTRO_NAME does not exist (not WSL)
    PUSH="git push origin"
else # The environment WSL_DISTRO_NAME exists (is WSL)
    PUSH="powershell.exe git push origin"
fi

git tag $VERSION # Create a version tag

if [ $(git tag -l $MAJOR) ]; then #If the MAJOR version tag exists
    git tag -d $MAJOR # Delete the old MAJOR version tag
    $PUSH :$MAJOR # Delete the MAJOR version tag from the remote
fi

git tag $MAJOR # Create a new MAJOR version tag
$PUSH main $VERSION $MAJOR --atomic