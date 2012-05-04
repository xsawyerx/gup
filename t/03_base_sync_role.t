use strict;
use warnings;
use Test::More tests => 3;
use Test::Fatal;
use t::lib::Functions;

use Gup;

{
    package Gup::TestSync;
    use Moo;
    with 'Gup::Role::Sync';
    sub sync{}
}

like(
    exception {
        package Gup::TestSync::NoSync;
        use Moo;
        with 'Gup::Role::Sync';
    },
    qr/^Can't apply Gup::Role::Sync to Gup::TestSync::NoSync - missing sync/,
    'Gup::Role::Sync requires a sync method',
);

my $gup = t::lib::Functions::create_test_gup;

like(
    exception { Gup::TestSync->new( gup => $gup ) },
    qr/^Missing required arguments: source_dir/,
    'Gup::Role::Sync requires a source_dir',
);

isa_ok(
    Gup::TestSync->new(
        gup        => $gup,
        source_dir => 'test_remote_dir',
    ),
    'Gup::TestSync',
);
