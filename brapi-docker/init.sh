#!/bin/bash

# Automatically exit on error.
set -e

# cd /opt/drupal/

# Check if Drupal extensions must be installed.
if [ ! -e web/modules/contrib/brapi ]; then
  echo "Downloading Drupal extensions..."
  # Install Drupal extensions.
  composer config minimum-stability dev \
    && composer -n require drush/drush \
    && composer -n require drupal/brapi \
    && composer -n require drupal/token \
    && composer -n require drupal/geofield \
    && composer -n require drupal/dbxschema \
    && composer -n require drupal/external_entities \
    && composer -n require drupal/imagecache_external \
    && composer -n require drupal/xnttdb \
    && composer -n require drupal/xnttbrapi \
    && composer -n require drupal/xnttfiles \
    && composer -n require drupal/xnttexif-xnttexif \
    && composer -n require drupal/xnttjson \
    && composer -n require drupal/xnttmanager \
    && composer -n require drupal/xnttmulti \
    && composer -n require drupal/xnttstrjp \
    && composer -n require drupal/xntttsv \
    && composer -n require drupal/xnttxml \
    && composer -n require drupal/xnttyaml \
    && composer -n require drupal/gbif2 \
    && composer -n require drupal/xnttviews
  # @todo: add other modules...
  #   && composer -n require drupal/chadol
  echo "...Drupal extensions download done."
else
  echo "Drupal extensions already downloaded."
fi

# Check if the database is already initialized.
# Wait for database ready (3 minutes max).
loop_count=0
while ! pg_isready -h db -p 5432  && [[ "$loop_count" -lt 180 ]]; do
  echo "."
  loop_count=$((loop_count+1))
  sleep 1
done
if [[ "$loop_count" -ge 180 ]]; then
  echo "ERROR: Failed to wait for PostgreSQL database. Stopping here."
  exit 1
fi
echo "Database seems ready."

if [ "$( psql -h db -U postgres -XtAc "SELECT 1 FROM pg_database WHERE datname='drupal';" )" = '1' ]; then
  # Database already initialized.
  echo "Database already initialized."
else
  # Initialize database...
  echo "Setup database..."
  # Setup PostgreSQL.
  psql -h db -U postgres --command="CREATE DATABASE drupal WITH OWNER postgres;"
  psql -h db -U postgres drupal --command="CREATE EXTENSION pg_trgm;CREATE EXTENSION fuzzystrmatch;"
  echo "...database setup done."

  echo "Setup Drupal..."
  if [ ! -e web/sites/default/settings.php ]; then
    cp web/sites/default/default.settings.php web/sites/default/settings.php
  fi
  if [ ! -e web/sites/default/services.yml ]; then
    cp web/sites/default/default.services.yml web/sites/default/services.yml
  fi
  if [ ! -e web/sites/default/external_dbs.php ]; then
    cp external_dbs.php web/sites/default/external_dbs.php
  fi
  # Append some settings.
  echo -e "\n\$settings['config_sync_directory'] = '../config/sync';\n\$settings['file_private_path'] = '/opt/drupal/private/';\n" >>web/sites/default/settings.php
  # Enable and configure Drupal CORS to allow REST and token authentication...
  # - enabled: true
  perl -pi -e 'BEGIN{undef $/;} s/^(  cors.config:\s*\n(?:    [^\n]+\n|\s*\n|\s*#[^\n]*\n)*)    enabled:\s*false/$1    enabled: true/smig' web/sites/default/services.yml
  # - allowedHeaders: ['authorization','content-type','accept','origin','access-control-allow-origin','x-allowed-header']
  perl -pi -e 'BEGIN{undef $/;} s/^(  cors.config:\s*\n(?:\s*\n|    [^\n]+\n|    #[^\n]*\n)*)    allowedHeaders:[^\n]*/$1    allowedHeaders: ['"'"'authorization'"'"','"'"'content-type'"'"','"'"'accept'"'"','"'"'origin'"'"','"'"'access-control-allow-origin'"'"','"'"'x-allowed-header'"'"']/smig' web/sites/default/services.yml
  # - allowedMethods: ['*']
  perl -pi -e 'BEGIN{undef $/;} s/^(  cors.config:\s*\n(?:    [^\n]+\n|\s*\n|\s*#[^\n]*\n)*)    allowedMethods:[^\n]*/$1    allowedMethods: ['"'"'*'"'"']/smig' web/sites/default/services.yml
  # Allow setting update by Drupal installation process.
  # Permissions will be automatically reset after installation.
  chmod uog+w  web/sites/default/settings.php

  # Install Drupal.
  /opt/drupal/vendor/drush/drush/drush -y site-install standard \
    --db-url=pgsql://postgres:pgBr4P!_D0cker@db/drupal \
    --account-mail="brapi@localhost" \
    --account-name=brapi \
    --account-pass="Br4P!_D0cker" \
    --site-mail="brapi@localhost" \
    --site-name="BrAPI Docker Alpha 1"

  # Append auto-include for external databases settings in "external_dbs.php".
  echo -e "\n\nif (file_exists(\$app_root . '/' . \$site_path . '/external_dbs.php')) {\n  include \$app_root . '/' . \$site_path . '/external_dbs.php';\n}\n" >>web/sites/default/settings.php

  # Other config stuff.
  chmod -R uog+w private config web/sites/default/files
  
  echo "...Drupal setup done."

  echo "Setup Drupal extensions..."
  # Enable modules.
  drush -y pm-enable dbxschema_pgsql dbxschema_mysql xnttdb brapi
  echo "...Drupal extensions setup done."

fi

# Update PHP config.
if [[ ! -e php ]] || [[ ! -e php/php.ini ]]; then
  # First time, copy PHP settings on a mountable volume.
  mkdir -p php
  cp "$PHP_INI_DIR/php.ini" php/php.ini
else
  # If (volume) Drupal php.ini exists, replace the system one with it.
  cp php/php.ini "$PHP_INI_DIR/php.ini"
fi

# Launch PHP-fpm
php-fpm
