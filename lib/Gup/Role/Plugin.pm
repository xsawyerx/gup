use strict;
use warnings;
package Gup::Role::Plugin;
# ABSTRACT: Plugin role for Gup

use Moo::Role;
use Sub::Quote;

with 'Gup::Role::Plugin';

has gup => (
    is       => 'ro',
    isa      => quote_sub( q{
        ref( $_[0] ) && ref( $_[0] ) eq 'Gup'
            or die "Improper gup attribute\n";
    } ),
    required => 1,
);

1;

__END__

