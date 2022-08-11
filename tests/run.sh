#!/usr/bin/env sh

BASEDIR=$(dirname "$0")

function test_case() {
  echo -e "\033[0;33m$1\033[0;0m"

  "${@:2}"

  if [ 0 -ne "$?" ]; then
    echo -e "\033[0;31mTest failed.\033[0;0m"
  fi
}

docker container run --rm -v "$(pwd)/$BASEDIR:/app/" "$1" php iconv.php


docker container run --rm -v "$(pwd)/$BASEDIR:/app/" "$1" sh -c 'echo "$PHP_SUFFIX" && echo "$BUILD_CONFIG_SUPERVISOR" && echo "$BUILD_CONFIG_PHP" && echo "$BUILD_CONFIG_PHP_FPM" && echo "$BUILD_CONFIG_NGINX"'

test_case "Check if dir /home/www-data/log exists." docker container run --rm -v "$(pwd)/$BASEDIR:/app/" "$1" test -d /home/www-data/log
test_case "Check if dir /home/www-data/tmp exists." docker container run --rm -v "$(pwd)/$BASEDIR:/app/" "$1" test -d /home/www-data/tmp
test_case "Check if dir /.composer exists." docker container run --rm -v "$(pwd)/$BASEDIR:/app/" "$1" test -d /.composer
