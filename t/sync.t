#!perl

use strict;
use warnings;

use Gup;
use Test::More tests => 4;

my $gup = Gup->new( name => 'blah', sync_class => 'Rsync' );
isa_ok( $gup, 'Gup' );

$gup->_build_syncer;

{
    my $count;

    no warnings qw/redefine once/;
    *Gup::Sync::Rsync::sync = sub {
        my $self = shift;
        my ( $from, $to ) = @_;

        isa_ok( $self, 'Gup::Sync::Rsync' );
        is( $from, 'from', 'Correct from' );
        is( $to,   'to',   'Correct to'   );

        return $count++;
    };
}

$gup->sync( 'from', 'to' );

