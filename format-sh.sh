#!/usr/bin/env bash

[[ -z $1 ]] && echo "Usage: $0 file.sh" && exit 1

./shfmt -ln bash -i 4 -w "$1"
