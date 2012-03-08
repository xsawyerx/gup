#!perl

use strict;
use warnings;

use Gup;
use Test::More tests => 6;
use Test::Fatal;

{
    package A;
    sub new { bless {}, shift }
}

{
    package Gup::Sync::A;
    sub new { bless {}, shift }
}

like(
    exception { Gup->new( name => 'blah', syncer => A->new ) },
    qr/^\Qsyncer must be a Gup::Sync:: object\E/,
    'Cannot create gup with improper syncer object',
);

is(
    exception { Gup->new( name => 'a', syncer => Gup::Sync::A->new ) },
    undef,
    'Can create new Gup with proper syncer',
);

my $gup = Gup->new(
    name       => 'blah',
    sync_class => 'Rsync',
    source_dir => 'from',
);

isa_ok( $gup, 'Gup' );

# call the builder so it loads the namespaces so that we could override it
$gup->_build_syncer;

{
    my $count;

    no warnings qw/redefine once/;
    *Gup::Sync::Rsync::sync = sub {
        my $self = shift;
        my ( $from, $to ) = @_;

        isa_ok( $self, 'Gup::Sync::Rsync' );
        is( $from, 'from',                'Correct from' );
        is( $to,   '/var/gup/repos/blah', 'Correct to'   );

        return $count++;
    };
}

$gup->sync_repo();

