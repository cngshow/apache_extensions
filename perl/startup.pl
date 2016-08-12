#This file is used to setup the include path for mod_perl
#In this case, in the directory '/etc/httpd/scripts/modules',
#we expect a subfolder called Prisme to contain the file ValidateHeaders.pm
#where pm is a perl module
#lives in /etc/httpd/scripts/
use lib qw(/etc/httpd/scripts/modules);
 1;
# PerlRequire /etc/httpd/scripts/startup.pl
#above must be httpd.conf