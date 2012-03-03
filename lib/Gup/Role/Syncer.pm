use strict;
use warnings;
package Gup::Role::Syncer;
# ABSTRACT: Syncing role for Gup

use Moo::Role;

requires 'sync';

has host => (
    is       => 'ro',
    isa      => quote_sub( q{
        $_[0] =~ /^(?:[A-Za-z0-9_-]|\.)+$/ or die "Improper host: '$_[0]'\n";
    } ),
    required => 1,
);

1;

__END__

