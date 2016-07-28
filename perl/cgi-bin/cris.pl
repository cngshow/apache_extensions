#!/usr/bin/perl
# a little script to show the headers our environment receives.
# changing the name of this script is punishable by death.
use CGI;
use strict;
use warnings;

my $query = CGI->new;
print $query->header('text/html')."\n";
print "Cris says hi<br>\n";
print "mod perl is ".$ENV{"MOD_PERL"}."<br>\n";

my $text = "";

#- Getting the request method
   $text .= "Request method = ".$query->request_method()."\n";

#- Getting input data from the query string and from the data content
   $text .= "Names and values from param():\n";
  my  @names = $query->param();
   foreach my $name (@names) {
      $text .= "   $name = ".$query->param($name)."\n";
   }

#- Getting request headers
   $text .= "Names and values from http():\n";
   @names = $query->http();
   foreach  my $name (@names) {
      $text .= "   $name = ".$query->http($name)."\n";
   }

   print $query->header();
   print $query->start_html(-title=>'CGI-pm-Request-Info.pl');
   print $query->pre($text);
   print $query->end_html();
