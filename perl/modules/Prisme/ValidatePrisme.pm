#must be in a directory named 'Prisme'
package Prisme::ValidateHeader;

use strict;
use warnings;
use Apache2::Const qw(FORBIDDEN OK);
use Apache2::Log;
use Apache2::RequestRec;
use APR::Table;
require 'constants.pl';
use LWP::UserAgent;
use URI;
my $ua = LWP::UserAgent->new( ssl_opts => { verify_hostname => 0 } );
use JSON;

#print "My lease will last for $CONST::SECONDS_CACHE seconds!\n";
my %cache_hash;
$cache_hash{'lease'} = {};
$cache_hash{'roles'} = {};
my $json_decoder_ring = JSON->new;

sub allowed($$) {
	my $roles      = shift;
	my $logger = shift;
	my @role_names = @$roles;

	my %union = my %isect = ();
	no warnings;
	foreach my $e ( @role_names, @$CONST::REQUIRED_ROLES ) {
		$union{$e}++ && $isect{$e}++;
	}
	use warnings;
	my @isect = keys %isect;
	if ( scalar @isect ) {
		#we have at least one role we need.
		#send OK
		#print "All is good!!!\n";
		$logger->info("Returning OK!");
		return OK;
	}
	else {
		#we have none of the roles we need
		#send forbidden
		#warn "You are a hacker!\n";
		$logger->info("Returning FORBIDDEN!");
		return FORBIDDEN;
	}
}

sub rest_call($$) {
	my $user_name = shift;
	my $logger = shift;
	my $return_code;
	$logger->info("Rest call for $user_name");
	unless ( defined $cache_hash{'lease'}->{$user_name} ) {
		$cache_hash{'lease'}->{$user_name} = 0;
		#print $cache_hash{'lease'}->{$user_name} . "\n";
	}
	if ( ( time - $cache_hash{'lease'}->{$user_name} ) > $CONST::SECONDS_CACHE )
	{
		$logger->info( "Rerunning role fetch for user $user_name");

		no warnings;
		my $url = URI->new($CONST::PRISME_ROLES_URL);
		$url->query_form( $CONST::CGI_USER_NAME => $user_name );
		$logger->info("Prisme URL is: $url");    # so we can see it
		                     # Create a request
		my $req = HTTP::Request->new( GET => $url );

		# Pass request to the user agent and get a response back
		my $res     = 0;
		my $roles   = 0;
		my $content = 0;
		eval {
		  #we will trap any errors during the fetch and parse.
		  #parsing will fail if we cannot cannect to Prisme or
		  #if we get invalid JSON.  We will log the error, and send a forbidden.
			$res     = $ua->request($req);
			$content = $res->content;
			$logger->info("The roles from prisme are:\n $content")
			$roles   = $json_decoder_ring->decode($content);
		};
		unless ($roles) {
			$logger->error("Failed to get Prisme roles!");
			$logger->error("Prisme returned: $content") if $content;
			$logger->error("$@");
			$logger->error("$!");
			$logger->error("Returning forbidden due to failure!");
			return FORBIDDEN;    #return FORBIDDEN code
		}
		my @role_names = map { $_->{$CONST::JSON_ROLE_NAME_KEY} } @$roles;
		$cache_hash{'roles'}->{$user_name} = \@role_names;
		$return_code = allowed( \@role_names,$logger );
		use warnings;
		$cache_hash{'lease'}->{$user_name} = time;
	}
	else {
		$logger->info("Using role cache for user $user_name");
		$return_code = allowed( $cache_hash{'roles'}->{$user_name}, $logger );
	}
	$return_code;
}

sub apr_iterator {
	my ( $key, $value ) = @_;
	warn "DATA: $key => $value\n";    #goes to  /var/log/httpd/error_log
	return 1;
}

sub handler {
	my $r = shift;
	my $user = $r->headers_in->get('ADSAMACCOUNTNAME');
	$r->log->info("The user for this request is $user");
	return rest_call($user,$r->log);
}
	#$r->log_error("--->request: log_error");
	#$r->log("request: regular log");
	#warn "DATA: -----------------------------------------------------------------";
	#$r->headers_in()->do("apr_iterator");
	#warn "DATA: -----------------------------------------------------------------";

#note, the HTTP_ portion should not be included.
#return OK unless $r->headers_in->EXISTS('SM_UNIVERSALID');#Shouldn't need this line in PerlFixupHandler lifecycle phase
# in a meeting with:
#Ray Shapouri
#Mohammad.Shapouri@va.gov
#We have been advised to switch to:
#HTTP_ADSAMACCOUNTNAME
	#$r->log->info("CRIS 1--->request: log_info");
	#$r->log_error("The user is $user");
	#return OK if (($user eq 'vhaiswshuppc') || ($user eq 'VHAISPBOWMAG') ||($user eq 'vacocuestc'));
	#return FORBIDDEN;

1;