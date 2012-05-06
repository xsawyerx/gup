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

1;

__END__
