use strict;
use warnings;
use Test::More;
use Test::Fatal;

use t::lib::Functions;

use Gup;

{
    package Gup::TestPlugin;
    use Moo;
    with 'Gup::Role::Plugin';
}

plan tests => 2;

like(
    exception { Gup::TestPlugin->new },
    qr/^Missing required arguments: gup/,
    'Gup->new requires a repo_dir',
);

my $gup = t::lib::Functions::create_test_gup;

isa_ok( Gup::TestPlugin->new( gup => $gup ), 'Gup::TestPlugin' );

done_testing;
