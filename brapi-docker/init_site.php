<?php
use Drupal\node\Entity\Node;
use Drupal\user\Entity\Role;
use Drupal\user\RoleInterface;

// Create homepage.
$node = Node::create([
  'type' => 'page',
  'title' => 'Welcome to BrAPIMapper',
  'body' => [
    'value' => 'This is the BrAPI administration site.<br/>You can <a href="/admin/structure/external-entity-types">create new external data mappings</a> and then <a href="/brapi/admin">setup BrAPI service</a>, <a href="/brapi/admin/datatypes">BrAPI mapping</a> and <a href="/brapi/admin/calls">BrAPI calls</a>.',
    'summary' => '',
    'format' => 'full_html',
  ],
  'uid' => 1,
  'status' => TRUE,
  'promote' => TRUE,
  'sticky' => FALSE,
  'path' => [
    'alias' => '/home',
  ],
]);
$node->save();

// Allow anonymous users to access BrAPI calls by default.
$roles = Role::loadMultiple([
  RoleInterface::ANONYMOUS_ID,
  RoleInterface::AUTHENTICATED_ID
]);

$all_permissions = [
  'use brapi',
];

foreach ($all_permissions as $permission) {
  $roles[RoleInterface::AUTHENTICATED_ID]->grantPermission($permission);
  $roles[RoleInterface::ANONYMOUS_ID]->grantPermission($permission);
}

$roles[RoleInterface::AUTHENTICATED_ID]->save();
$roles[RoleInterface::ANONYMOUS_ID]->save();
