package CONST;
no warnings;

#System administrator have at the following:
#number of seconds we will cache a users roles for
$SECONDS_CACHE = 5*60; #every five minutes re-fetch.
$PRISME_ROLES_URL = 'https://vaauscttdbs80.aac.va.gov:8080/rails_prisme/roles/get_ssoi_roles.json';
#$PRISME_ROLES_URL = 'http://localhost:3000/roles/get_ssoi_roles.json';
$ROLES_BY_CONTEXT = {'ntrt' => ['super_user', 'ntrt']}; #roles tied to the context
#$ROLES_BY_CONTEXT = {'jenkins' => ['super_user', 'Approver'], 'ntrt' => ['super_user', 'NTRT']}; #multi context example
$DEFAULT_ROLES = ['super_user','administrator']; # If the context is not listed above then at least one of these role must be present to prevent the dreaded 'FORBIDDEN'!
$CGI_USER_NAME = 'id';
$LOG_HEADERS=0; #0 is false 1 is true, logs at the info log level.
$ACCEPT_ALL_REQUESTS=0; #if 0 works as expected (role validation occurs), if 1 role validation is disabled
1;