use strict;
use warnings;
package Gup::Role::Sync;
# ABSTRACT: Sync role for Gup

use English '-no_match_vars';
use Moo::Role;
use Sub::Quote;
use MooX::Types::MooseLike::Base qw/Str/;

requires 'sync';

with 'Gup::Role::Plugin';

has ssh_path => (
    is       => 'ro',
    isa      => Str,
    default  => quote_sub( q{'/usr/bin/ssh'} ),
);

has scp_path => (
    is       => 'ro',
    isa      => Str,
    default  => quote_sub( q{'/usr/bin/scp'} ),
);

has host => (
    is       => 'ro',
    isa      => quote_sub( q{
        $_[0] =~ /^(?:[A-Za-z0-9_-]|\.)+$/ or die "Improper host: '$_[0]'\n";
    } ),
    predicate => 'has_host',
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
