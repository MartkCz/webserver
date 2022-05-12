# PHP-8.1 alpine 

https://hub.docker.com/repository/docker/martkcz/php-alpine

## Production
```dockerfile

RUN configure php
RUN configure php-fpm

USER root

# PHP
RUN cp 99_settings.ini /etc/php$PHP_SUFFIX/conf.d/
    
# PHP-fpm    
RUN cp www.conf /etc/php$PHP_SUFFIX/php-fpm.d/

USER www-data
```

## Production ini example

```ini
max_execution_time = 60
realpath_cache_ttl = 600
max_input_time = 30
memory_limit = 64M
post_max_size = 32M
upload_max_filesize = 32M

; Short tags
asp_tags = Off
short_open_tag = Off

; Errors
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
display_errors = Off
display_startup_errors = Off
log_errors = On
log_errors_max_len = 1024
ignore_repeated_errors = Off
report_memleaks = Off
track_errors = Off
error_log = /dev/stderr

; Opcache
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=64
opcache.max_accelerated_files=32531
opcache.validate_timestamps=0
opcache.save_comments=1
opcache.fast_shutdown=0
```
