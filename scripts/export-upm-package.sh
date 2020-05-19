#!/bin/bash -eu

upm_name=org.khronos.UnityGLTF
upm_src_folder_path=$(pwd)/UnityGLTF/Assets/UnityGLTF
upm_manifest_path=$(pwd)/scripts/package.json
upm_staging_path=$(pwd)/current-package/$upm_name
upm_staging_plugins_path="$upm_staging_path/UnityGLTF/Plugins"


# For the UPM we only want to keep the GLTFSerialization dll
# This is because we get the NewtonsoftJSON dependency via a UPM dependency declared in package.json

PLUGIN_FILES_TO_KEEP=(
	"GLTFSerialization.dll"
	"GLTFSerialization.dll.meta"
	"GLTFSerialization.pdb"
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
    echo

    for entry in "$pluginDir"/*
    do
        file=$(basename "$entry")
        if ! keep_plugin_file "$file" ; then
            # echo "Removing $file"
            rm -rf "$entry"
        fi
    done
}

echo $upm_name
echo "$upm_src_folder_path"
echo "$upm_manifest_path"
echo "$upm_staging_path"

echo "Creating package folder"
rm -rf "$upm_staging_path"
mkdir "$upm_staging_path"
echo "Copying package.json"
cp "$upm_manifest_path" "$upm_staging_path"

echo "Copying package contents from $upm_src_folder_path"
cp -r "$upm_src_folder_path" "$upm_staging_path"

echo "Cleaning out plugin DLLs that are provided by other means when using UPM"
clean_plugin_dir "$upm_staging_plugins_path/net35"
clean_plugin_dir "$upm_staging_plugins_path/netstandard1.3"
clean_plugin_dir "$upm_staging_plugins_path/uap10.0.10586"

echo
echo "Removing Examples, Tests"
cd "$upm_staging_path/UnityGLTF"
rm -rf Examples Tests Examples.meta Tests.meta

# Remove .gitignore; it is also used when publishing via npm and we do not want npm ignoring the plugins.
rm -f "$upm_staging_path/UnityGLTF/.gitignore"

echo
echo "Be sure to modify $upm_staging_path/package.json"
echo "Set the version appropriately before attempting to publish the package to a UPM registry."
