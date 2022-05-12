#!/usr/bin/env sh

BASEDIR=$(dirname "$0")

docker run --rm --user="$(id -u):$(id -g)" "$1"
