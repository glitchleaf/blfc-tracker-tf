#!/usr/bin/env bash

php artisan config:cache
php artisan route:cache
php artisan event:cache
php artisan view:cache
exec supervisord -n -c /etc/supervisor.d/supervisord.ini
