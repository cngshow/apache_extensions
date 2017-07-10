## apache_extensions 

mod_perl and mod_proxy can work together to provide authentication mechanisms 
within apache.  

In our case, on the va-ctt project, we must integrate the Department 
of Veterans Affairs Single Sign On software with software such as Nexus and Jenkins
despite the fact that this software does not integrate out of the box. 
This 
guide will document how to accomplish this.



mod_perl:


mod_perl must be installed against the apache webserver:
```
yum -y install mod_perl
```

after the install you should have a perl.conf file, 
for example:
```
/etc/httpd/conf.d/perl.conf
```



To validate your install add the following to perl.conf:


```
Alias /perl/ /var/www/cgi-bin/
<Location /perl>
    SetHandler perl-script
    PerlResponseHandler ModPerl::Registry
    PerlOptions +ParseHeaders
    Options +ExecCGI
    Order deny,allow
    Allow from all
</Location>
```



place cris.pl in:
```
/var/www/cgi-bin/
```

cris.pl is dependent on Perl's CGI.pm module (note some versions of CPAN do not require and will not allows the 'install' keyword):
```
cpan install CGI
```
When hitting your url, perhaps:
```
https://myserver/perl/cris.pl
```
If you see a page that shows you the mod perl version and your header info,
you have succeeded.



Now to configure header validation. In httpd.conf include this line:
```
PerlRequire /etc/httpd/scripts/startup.pl
```
Obviously, startup.pl should be there. startup.pl is what tells mod_perl
 how to find your various custom modules for extending apache. 
This file modifies
Perl's include path appropriately so perl can find all referenced source code.

Now in httpd.conf add:
```
<Location />
  PerlFixupHandler Prisme::ValidateHeader
</Location>
```


*NOTE::  This header validator can be configured in Apache's \<Location\>,
\<Directory\> or \<Files\> section.  
This current config will only run the validator 
against the root path ('/').  More research is needed to enhance the config to run where needed.

A quick examination of startup.pl shows us that:
```
/etc/httpd/scripts/modules
```
is on the include path.  We need to ensure that the subdirectory 'Prisme' is present
and that it contains the perl module 'ValidatePrisme.pm'

ValidatePrisme.pm needs the following software installed, (keep in mind 'install' might not be required):
```
cpan install LWP
cpan install JSON::Parse
```

There is a file called constants.pl, you must add it in httpd.conf:
```
PerlRequire /etc/httpd/scripts/constants.pl
```

I put it right below startup.pl.  This file is engineered to be easy for a sys admin to modify.
It looks partly like this:
```
#System administrator have at the following:
#number of seconds we will cache a users roles for
$SECONDS_CACHE = 5*60; #every five minutes re-fetch.
$PRISME_ROLES_URL = 'https://vaauscttdbs80.aac.va.gov:8080/rails_prisme/roles/get_ssoi_roles.json';
#$PRISME_ROLES_URL = 'http://localhost:3000/roles/get_ssoi_roles.json';
$REQUIRED_ROLES = ['super_user','administrator']; #at least one of these role must be present to prevent the dreaded 'FORBIDDEN'!
$CGI_USER_NAME = 'id';
$JSON_ROLE_NAME_KEY = 'name';
$LOG_HEADERS=0; #0 is false 1 is true, logs at the info log level.
$ACCEPT_ALL_REQUESTS=0; #if 0 works as expected (role validation occurs), if 1 role validation is disabled
```

our mod perl module does quite a bit of logging.  To set log levels look for something
like this in the appropriate .conf file
```
# Use separate log files for the SSL virtual host; note that LogLevel
# is not inherited from httpd.conf.
ErrorLog logs/ssl_error_log
TransferLog logs/ssl_access_log
LogLevel warn
```

The initial implementation allows Claudio's and Cris' accounts access and denies all
others.

*NOTE:: logging occurs in /var/log/httpd*

mod_proxy 

######################

mod_proxy:

The objective is to forward/proxy the incoming request over ssl to its final destination.
In this initial implementation, we are proxying / (root) over to the destination server.
We have to nest the mod_proxy config in the ssl.conf file under httpd/conf.d/ssl.conf
In this initial implementation we aren't using VirtualHost(s) yet.

mod_proxy config:


# We must load the following modules:
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so

# Add the following directives:
ProxyRequests Off
ProxyPreserveHost On
ProxyPass        / https://vaservername:4848
ProxyPassReverse / https://vaservername:4848

# Need to research Access Control for the version of httpd we are running in the VAservers:
# http://httpd.apache.org/docs/2.4/upgrading.html#run-time

...


