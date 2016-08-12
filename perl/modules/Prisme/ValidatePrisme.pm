use strict;
use warnings;
require 'constants.pl';
use LWP::UserAgent;
use URI;
my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 });
use JSON::Parse 'parse_json';
# try 'cpan install JSON::Parse'

print "My lease will last for $CONST::SECONDS_CACHE seconds!\n";
my %cache_hash;
$cache_hash{'lease'} = {};
$cache_hash{'roles'} = {};


sub allowed($) {
    my $roles = shift;
    my @role_names = @$roles;


    my %union = my %isect = ();
    no warnings;
    foreach my $e ( @role_names, @$CONST::REQUIRED_ROLES ) {
        $union{$e}++ && $isect{$e}++;
    }
    use warnings;
    my @isect = keys %isect;
    if ( scalar @isect ) {
        #send OK
        print "All is good!!!\n";
    }
    else {
        #send forbidden
        warn "You are a hacker!\n";
    }
}





sub rest_call($) {
    my $user_name = shift;
    print "user is $user_name\n";
    unless ( defined $cache_hash{'lease'}->{$user_name} ) {
        $cache_hash{'lease'}->{$user_name} = 0;
        print $cache_hash{'lease'}->{$user_name} . "\n";
    }
    if ( ( time - $cache_hash{'lease'}->{$user_name} ) > $CONST::SECONDS_CACHE )
    {
        print "Rerunning role fetch for user $user_name\n";


        no warnings;
        my $url = URI->new($CONST::PRISME_ROLES_URL);
        $url->query_form( $CONST::CGI_USER_NAME => $user_name );
        print $url, "\n";    # so we can see it
                             # Create a request
        my $req = HTTP::Request->new( GET => $url );


        # Pass request to the user agent and get a response back
        my $res        = 0;
        my $roles      = 0;
        my $content = 0;
        eval {
            #we will trap any errors during the fetch and parse.
            #parsing will fail if we cannot cannect to Prisme or
            #if we get invalid JSON.  We will log the error, and send a forbidden.
            $res = $ua->request($req);
            $content = $res->content;
            $roles = parse_json($content);
        };
        unless ($roles) {
            warn "Failed to get Prisme roles!\n";
            warn "Prisme returned: $content\n" if $content;
            warn "$@\n";
            warn "$!\n";
            return 0; #return FORBIDDEN code
        }
        my @role_names = map { $_->{$CONST::JSON_ROLE_NAME_KEY} } @$roles;
        $cache_hash{'roles'}->{$user_name} = \@role_names;
        allowed(\@role_names);
        use warnings;
        $cache_hash{'lease'}->{$user_name} = time;
    }
    else {
        print "Using role cache for user $user_name\n";
        allowed($cache_hash{'roles'}->{$user_name});
    }
}