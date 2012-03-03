use strict;
use warnings;
package Gup::Role::Syncer;
# ABSTRACT: Syncing role for Gup

use English '-no_match_vars';
use Moo::Role;
use Sub::Quote;

requires 'sync';

has host => (
    is       => 'ro',
    isa      => quote_sub( q{
        $_[0] =~ /^(?:[A-Za-z0-9_-]|\.)+$/ or die "Improper host: '$_[0]'\n";
    } ),
    required => 1,
);

# these two could be separated at some point to Gup::Role::SyncUser
# also, they could also be added to Gup::Role::SyncAuthUser / SyncUser
# one would make these required while others won't
# this would make web sync possible with optional user/pass authentications
has username => (
    is       => 'ro',
    isa      => quote_sub( q{
        $_[0] =~ /^(?:[A-Za-z0-9_-]|\.)*$/ or die "Improper user: '$_[0]'\n";
    } ),
    builder  => '_build_username',
);

sub _build_username { getpwuid $REAL_USER_ID }

1;

__END__

