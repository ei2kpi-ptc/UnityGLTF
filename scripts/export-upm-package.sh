#!/bin/bash -eu
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

UPM_NAME=org.khronos.UnityGLTF

# Tell CI the UPM_NAME.
echo "##vso[task.setvariable variable=UPM_NAME]$UPM_NAME"

UPM_SOURCE_FOLDER_PATH="${REPO_ROOT}/UnityGLTF/Assets/UnityGLTF"
UPM_OVERLAY_PATH="${SCRIPT_DIR}/upm_overlay"
UPM_STAGING_PATH="${REPO_ROOT}/current-package/${UPM_NAME}"
UPM_STAGING_PLUGINS_PATH="${UPM_STAGING_PATH}/UnityGLTF/Plugins"

set +u
# This chunk is only necessary for CI
# This is so that Azure Pipelines can attach the build artifacts to the tagged
# released in GitHub.
if [[ $BUILD_SOURCEBRANCH == *"refs/tags"* ]]; then
  echo "Detected refs/tags in $BUILD_SOURCEBRANCH so this must be a tagged release build."
  # Splits the string with "refs/tags", takes the second value and then
  # swaps out any slashes for underscores
  GIT_TAG=$(echo $BUILD_SOURCEBRANCH | awk -F'refs/tags/' '{print $2}' | tr '/' '_')
  echo "Setting GIT_TAG variable to: $GIT_TAG"
  # Tell CI the GIT_TAG
  echo "##vso[task.setvariable variable=GIT_TAG]$GIT_TAG"
else
  echo "Did not detect refs/tags in $BUILD_SOURCEBRANCH so skipping GIT_TAG variable set"
fi
set -u

# For the UPM we only want to keep the GLTFSerialization dll
# This is because we get the NewtonsoftJSON dependency via a UPM dependency declared in package.json

PLUGIN_FILES_TO_KEEP=(
	"GLTFSerialization.dll"
	"GLTFSerialization.dll.meta"
)

keep_plugin_file() {
    local seeking=$1
    local in=1
    for element in "${PLUGIN_FILES_TO_KEEP[@]}"; do
        if [[ $element == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}

clean_plugin_dir() {
    local pluginDir=$1
    echo "Removing unnecessary files from $pluginDir"

    for entry in "$pluginDir"/*
    do
        file=$(basename "$entry")
        if ! keep_plugin_file "$file" ; then
            # echo "Removing $file"
            rm -rf "$entry"
        fi
    done
}

echo $UPM_NAME
echo "$UPM_SOURCE_FOLDER_PATH"
echo "$UPM_STAGING_PATH"

echo
echo "Creating package folder"
rm -rf "$UPM_STAGING_PATH"
mkdir -p "$UPM_STAGING_PATH"

echo
echo "Copying UPM overlay"
cp -av "$UPM_OVERLAY_PATH/"* "$UPM_STAGING_PATH"

echo
echo "Copying package contents from $UPM_SOURCE_FOLDER_PATH"
cp -r "$UPM_SOURCE_FOLDER_PATH" "$UPM_STAGING_PATH"

echo
echo "Cleaning out plugin DLLs that are provided by other means when using UPM"
clean_plugin_dir "$UPM_STAGING_PLUGINS_PATH/net35"
clean_plugin_dir "$UPM_STAGING_PLUGINS_PATH/netstandard1.3"
clean_plugin_dir "$UPM_STAGING_PLUGINS_PATH/uap10.0.10586"

echo
echo "Removing Examples, Tests"
cd "$UPM_STAGING_PATH/UnityGLTF"
rm -rf Examples Tests Examples.meta Tests.meta

# Remove .gitignore; it is also used when publishing via npm and we do not want npm ignoring the plugins.
rm -f "$UPM_STAGING_PATH/UnityGLTF/.gitignore"

echo
echo "Be sure to modify $UPM_STAGING_PATH/package.json"
echo "Set the version appropriately before attempting to publish the package to a UPM registry."
