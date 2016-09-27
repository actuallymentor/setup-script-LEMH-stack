# DEPRECATED

Use the new [PHP7 Setup Script](https://github.com/actuallymentor/Setup-Script-Nginx-Pagespeed-PHP7-Mariadb) instead. It is equally powerful and less error prone.


# Setup script for LEMH stack

I refer to this as my supermegaukulele server. It's the fastest setup I know of so far.

Powerful server setup with Nginx (compiled with mod_pagespeed), MariaDB, HHVM and a PHP5-FPM fallback.

You work in Vagrant? https://github.com/actuallymentor/vagrant-smus

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
- Add config files for HHVM fallback, mod_pagespeed, cache and gzip
- Install MariaDB (MySQL dropin)
- Install PHP5-FPM
- Download and install HHVM
- Restart NginX

## You still need to:

- Run mysql_secure_installation

## Components

### Nginx

Faster than Apache webserver.

## Mod_pagespeed

A module made by google that automatically optimizes your code for fast delivery.

## MariaDB

Faster than MySQL database server, but works the same.

## HHVM

Runs PHP code superfast.

## PHP5-FPM

Backup for in case HHVM crashes, which it does sometimes.