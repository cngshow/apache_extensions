#must be in a directory named 'Prisme'
package Prisme::ValidateHeader;

use strict;
use warnings;
use Apache2::Const qw(FORBIDDEN OK);
use Apache2::Log;
use Apache2::RequestRec;
use APR::Table;

  sub apr_iterator {
      my ($key, $value) = @_;
      warn "DATA: $key => $value\n";#goes to  /var/log/httpd/error_log
      return 1;
  }

  sub handler {
      my $r = shift;
      $r->log_error("--->request: log_error");
      #$r->log("request: regular log");
      warn "DATA: -----------------------------------------------------------------";
      $r->headers_in()->do("apr_iterator");
      warn "DATA: -----------------------------------------------------------------";
      #note, the HTTP_ portion should not be included.
      return OK unless $r->headers_in->EXISTS('SM_UNIVERSALID');#Shouldn't need this line in PerlFixupHandler lifecycle phase
      # in a meeting with:
      #Ray Shapouri
      #Mohammad.Shapouri@va.gov
      #We have been advised to switch to:
      #HTTP_ADSAMACCOUNTNAME
      my $user = $r->headers_in->get('SM_UNIVERSALID');
      $r->log_error("The user is $user");
      return OK if ( ($user eq 'vhaiswshuppc') || $user eq ('vacocuestc'));
      return FORBIDDEN;
      #return FORBIDDEN#unless $r->method eq METHOD;

     # $r->server->method_register(METHOD);
     # $r->handler("perl-script");
     # $r->push_handlers(PerlResponseHandler => \&send_email_handler);

      #return OK;
  }

  1;