<?php

ini_set('display_errors', '1');
error_reporting(-1);
var_dump(iconv('UTF-8', 'ASCII//IGNORE//TRANSLIT', 'foo'));
var_dump(PHP_VERSION);
