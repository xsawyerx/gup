#!perl

use strict;
use warnings;

use Gup;
use Test::More tests => 4;

{
    package Gup::Sync::Test;

    sub new { bless {}, shift }
    my $count;

    sub sync {
        my $self = shift;
        my ( $from, $to ) = @_;

        isa_ok( $self, 'Gup::Sync::Test' );
        is( $from, 'from' );
        is( $to,   'to'   );

        return $count++;
    }
}

my $gup = Gup->new( name => 'blah', sync_class => 'Test' );
isa_ok( $gup, 'Gup' );
$gup->sync( 'from', 'to' );

