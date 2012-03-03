use strict;
use warnings;
package Gup::Role::Syncer;
# ABSTRACT: Syncing role for Gup

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
    required => 1,
);

has password => (
    is       => 'ro',
    isa      => quote_sub( q{
        chomp $_[0];
        length $_[0] > 0 or die "Improper password: '$_[0]'\n";
    } ),
    required => 1,
);

1;

__END__

