#!/bin/bash

if [ $# != 1 ]; then
    echo "specify the file name as an argument."
    exit 1
else
    :
fi


APP_DIR="$(pwd)/app"
APP_NAME=$1
TARGET_DIR="$APP_DIR/$APP_NAME"

dirs=(
    "$TARGET_DIR"
    "$TARGET_DIR/src"
    "$TARGET_DIR/examples"
    "$TARGET_DIR/modules"
    "$TARGET_DIR/modules/resource"
)

files=(
    "$TARGET_DIR/README.md"
    "$TARGET_DIR/.gitignore"
    "$TARGET_DIR/examples/providers.tf"
    "$TARGET_DIR/examples/main.tf"
    "$TARGET_DIR/examples/locals.tf"
    "$TARGET_DIR/examples/variables.tf"
    "$TARGET_DIR/examples/output.tf"
    "$TARGET_DIR/modules/resource/main.tf"
    "$TARGET_DIR/modules/resource/variables.tf"
    "$TARGET_DIR/modules/resource/output.tf"
)

for dir in "${dirs[@]}" ; do
    mkdir "$dir"
done
for file in "${files[@]}" ; do
    touch "$file"
done
