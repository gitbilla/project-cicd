#!/bin/bash
#### Script to push the changes to github #############

if [ -z "$1" ]; then
    echo "Usage: ./gitpush.sh \"commit message\""
    exit 1
fi

git add .
git commit -m "$1"
git push
