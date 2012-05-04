use strict;
use warnings;
use Test::More tests => 2;
use Test::Fatal;
use t::lib::Functions;

use Gup;

{
    package Gup::TestPlugin;
    use Moo;
    with 'Gup::Role::Plugin';
}

like(
    exception { Gup::TestPlugin->new },
    qr/^Missing required arguments: gup/,
    'Gup::Role::Plugin requires a gup',
);

my $gup = t::lib::Functions::create_test_gup;

isa_ok( Gup::TestPlugin->new( gup => $gup ), 'Gup::TestPlugin' );
