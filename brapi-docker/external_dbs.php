<?php

/**
 * Database settings:
 *
 * The $databases array specifies the database connection or
 * connections that Drupal may use.  Drupal is able to connect
 * to multiple databases, including multiple types of databases,
 * during the same request.
 *
 * The main database used by Drupal is specified in settings.php as
 * $databases['default']['default']. You can provide as many external databases
 * as neede by adding new $databases entries following the examples below.
 *
 * Just copy and uncomment the code below between the @code and @endcode lines
 * and paste after this comment section. You will need to replace the database
 * username and password and possibly the host and port with the appropriate
 * credentials for your database system and adjust you database permission
 * settings to allow the BrAPI docker to connect to them.
 *
 * @code
 * $databases['your_db1_id']['default'] = [
 *   'database' => 'databasename1',
 *   'username' => 'sqlusername1',
 *   'password' => 'sqlpassword',
 *   'host' => '192.168.0.2',
 *   'port' => '5432',
 *   'driver' => 'pgsql',
 *   'prefix' => '',
 * ];
 *
 * $databases['your_db1_id']['default'] = [
 *   'database' => 'databasename2',
 *   'username' => 'sqlusername2',
 *   'password' => 'sqlpassword',
 *   'host' => 'my.server.org',
 *   'port' => '3306',
 *   'driver' => 'mysql',
 *   'prefix' => '',
 *   'collation' => 'utf8mb4_general_ci',
 * ];
 * @endcode
 */
