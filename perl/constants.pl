package CONST;
no warnings;

#System administrator have at the following:
#number of seconds we will cache a users roles for
$SECONDS_CACHE = 5*60; #every five minutes re-fetch.
$PRISME_ROLES_URL = 'https://vaauscttdbs80.aac.va.gov:8080/rails_prisme/roles/get_ssoi_roles.json';
#$PRISME_ROLES_URL = 'http://localhost:3000/roles/get_ssoi_roles.json';
$REQUIRED_ROLES = ['super_user','administrator']; #at least one of these role must be present to prevent the dreaded 'FORBIDDEN'!
$CGI_USER_NAME = 'id';
$JSON_ROLE_NAME_KEY = 'name';
1;