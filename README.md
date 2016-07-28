## apache_extensions

mod_perl and mod_proxy can work together to provide authentication mechanisms
within apache.  In our case, on the va-ctt project, we must integrate the Department
of Veterans Affairs Single Sign On software with software such as Nexus and Jenkins
despite the fact that this software does not integrate out of the box. This
guide will document how to accomplish this.

mod_perl must be installed against the apache webserver:
```
yum -y install mod_perl
```

after the install you should have a perl.conf file, for example:
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

cris.pl is dependent on Perl's CGI.pm module:
```
cpan install CGI
```
When hitting your url, perhaps:
```
https://myserver/perl/cris.pl
```
If you see a page that shows you the mod perl version and your header info
you have succeeded.

Now to configure header validation. In httpd.conf include this line:
```
PerlRequire /etc/httpd/scripts/startup.pl
```
Obviously, startup.pl should be there.  startup.pl is what tells mod_perl
how to find your various custom modules for extending apache.  This file modifies
Perl's include path appropriately so perl can find all referenced source code.

Now in httpd.conf add:
```
<Location />
  PerlFixupHandler Prisme::ValidateHeader
</Location>
```
*NOTE::  This header validator can be configured in Apache's \<Location\>,
\<Directory\> or \<Files\> section.  This current config will only run the validator 
against the root path ('/').  More research is needed to enhance the config to run where needed.*


A quick examination of startup.pl shows us that:
```
/etc/httpd/scripts/modules
```
is on the include path.  We need to ensure that the subdirectory 'Prisme' is present
and that it contains the perl module 'ValidatePrisme.pm'

The initial implementation allows Claudio's and Cris' accounts access and denies all
others.

*NOTE:: logging occurs in /var/log/httpd*

mod_proxy config:

*to be updated by Claudio*
