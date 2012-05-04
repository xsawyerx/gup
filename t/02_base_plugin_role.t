use strict;
use warnings;
use Test::More tests => 4;
use Test::Fatal;
use t::lib::Functions;

use Gup;

{
    package Gup::Plugin::TestPlugin;
    use Moo;
    with 'Gup::Role::Plugin';
}

like(
    exception { Gup::Plugin::TestPlugin->new },
    qr/^Missing required arguments: gup/,
    'Gup::Role::Plugin requires a gup',
);

isa_ok(
    Gup::Plugin::TestPlugin->new( gup => t::lib::Functions::create_test_gup ),
    'Gup::Plugin::TestPlugin'
);

my $gup = Gup->new(
    repo_dir => t::lib::Functions::create_test_dir,
    plugins  => [ 'TestPlugin' ],
);

my @plugins = $gup->find_plugins('-Plugin');

cmp_ok( @plugins, '==', 1, 'Found one plugin' );
isa_ok( $plugins[0], 'Gup::Plugin::TestPlugin' );
