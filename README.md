# Setup script for LEMP with MariaDB, PHP7 and nginx Pagespeed module


What this script does:

- Add nginx repository
- Install dependencies
- Download nginx source
- Download Google's mod_pagespeed for nginx
- Configure nginx to compile with mod_pagespeed
- Make and install Nginx
- Download init scripts (credit JasonGiedymin)
- Add global nginx config
- Add default server config
- Install MariaDB (MySQL dropin)
- Install PHP7-FPM
- Configure auto security updates
- Restart NginX

## You still need to:

- Run mysql_secure_installation
- Enable caching in /etc/nginx/conf/fastcgicache.conf ( change set skip cache to 0 )

## Components

### Nginx

Faster than Apache webserver.

## Mod_pagespeed

A module made by google that automatically optimizes your code for fast delivery.

## MariaDB

Faster than MySQL database server, but works the same.

## PHP7-FPM

New php version.