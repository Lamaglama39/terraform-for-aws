#!/bin/bash

dir_targets=(
    ".terraform"
)
file_targets=(
    ".terraform.lock.hcl"
    "terraform.tfstate"
    "terraform.tfstate.backup"
)

for target in "${dir_targets[@]}" ; do
    find . -type d -name "$target" -exec rm -rf {} +
    echo "All $target have been deleted."
done

for target in "${file_targets[@]}" ; do
    find . -type f -name "$target" -exec rm -rf {} +
    echo "All $target have been deleted."
done
