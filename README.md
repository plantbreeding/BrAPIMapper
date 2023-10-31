BrAPIMapper
===========

Version: Beta 1
Date:    10/2023


Usage
-----

Start the service:
```
  # docker compose up -d
```

Stop the service:
```
  # docker compose down
```

The BrAPI service is available on port 8080. The administration interface is
available on port 8642.

The admin interface default login and password are "brapi" and "Br4P!_D0cker".
Please change that default password once you got in!


Architecture
------------
BrAPIMapper is using a set of 3 dockers managed by "docker compose":
- proxy: it uses the "nginx" container image to manage access to the BrAPI
  docker. It exposes 2 ports: 80 for BrAPI services (/brapi/v1/ and /brapi/v2/
  URLs) and 8642 for both Drupal/administration interface and BrAPI services.
  This offers the possibility to restrict access to BrAPI services only if
  needed by forwarding only the 80 port on a proxy.
  Note: the docker-compose file maps default port 80 to exposed port 8080.
- db: it uses the "postgres:15" container image to hold the Drupal database and
  parts of the site configuration (data mapping).
- brapi: a docker image based on "drupal:10.1.2-php8.2-fpm-bookworm" image.
  The brapi docker includes PHP-FPM and a pre-configured Drupal CMS with
  extensions.

The docker compose file ("docker-compose.yml") provides the "glue" between those
3 dockers.
2 ports are exposed: 8080 (BrAPI services) and 8642 (admin interface).
Database storage is made persistent with volume mapping: persistent PostgreSQL
data files are stored in "./data/pgdata".

Some parts of Drupal are also persistent in order to manage settings, extensions
and uploads.


Configuration
-------------

The "brapi.env" file contains initial settings and can be modified before the
first run of the container. After the first run, some changes may not be
possible (ie. not taken into account) or can prevent BrAPIMapper from running,
so change with care.

The first time "BrAPIMapper" is started, it will create persistent data
directories and provide initial config files that can be later customized. It
will pre-install and configure Drupal CMS and download extensions which will
take a couple of seconds/minutes. The next times, it will be faster as no
such things would be required anymore. However, if you let enabled the
auto-update feature (see "brapi.env"), the Drupal CMS and its module may also
get updated from times to times when you restart BrAPIMapper.

All Drupal-specific files are stored in the "./drupal" directory.

Drupal config file (settings.php) is stored in
"./drupal/drupal/sites/default/settings.php".

Additional external database can be added using the
"./drupal/drupal/sites/default/external_dbs.php" PHP file.

Custom files (not directly accessible through the nginx proxy) can be stored in
"./drupal/private".

NGINX proxy config can be modified in "./proxy/brapi-fpm.conf".

PHP config (php.ini) can be modified in "/opt/drupal/php/php.ini".

"Trusted Host Settings": this setting depends on the (public) server name
hosting the docker. It's a set of regular expression that can be used to match
the possible server names. It is set in
"./drupal/drupal/sites/default/settings.php".

Each time you update a config file, you will also need to restart BrAPIMapper in
order to have the changes taking effects.


Management
----------

Remove config and reinstall BrAPIMapper:
```
  # docker compose down
  # docker volume rm docker_drupal-volume
  # sudo rm -rf data drupal php
  # docker compose up -d
```


Maintainers
-----------

Current maintainers:

 * Valentin Guignon - v.guignon@cgiar.org

