#!/usr/bin/env sh

BASEDIR=$(dirname "$0")

docker container run --rm -v "$(pwd)/$BASEDIR:/app/" "$1" "php iconv.php"


docker container run --rm -v "$(pwd)/$BASEDIR:/app/" "$1" 'echo "$PHP_SUFFIX" && echo "$CONFIG_SUPERVISOR" && echo "$CONFIG_PHP" && echo "$CONFIG_PHP_FPM" && echo "$CONFIG_NGINX"'
