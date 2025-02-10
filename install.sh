#!/bin/bash

CONFIG_DIRECTORY=$(realpath "$(dirname "$0")")

excluded_directories=(
    ".git"
    ".githooks"
)
excluded_files=(
    "install.sh"
    "README.md"
)

exclude_directories=""
for directory in "${excluded_directories[@]}"; do
    exclude_directories+=" -type d -name '$directory' -prune -o "
done

exclude_files=""
for file in "${excluded_files[@]}"; do
    exclude_files+=" -not -name '$file' "
done

for file_path in $(eval "find '$CONFIG_DIRECTORY' $exclude_directories -type f $exclude_files -print"); do
    file_relative_path=${file_path#"$CONFIG_DIRECTORY/"}
    parent_relative_path=$(dirname "$file_relative_path")

    mkdir -p "$HOME/$parent_relative_path"
    ln -sf "$file_path" "$HOME/$file_relative_path"
done
