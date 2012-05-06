use strict;
use warnings;
use Test::More tests => 2;
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

isa_ok(
    Gup::TestSync->new(
        gup        => t::lib::Functions::create_test_gup,
        source_dir => 'test_remote_dir',
    ),
    'Gup::TestSync',
);
