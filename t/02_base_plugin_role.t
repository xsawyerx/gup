use strict;
use warnings;
use Test::More tests => 5;
use Test::Fatal;
use t::lib::Functions;

use Gup;

{
    package Gup::Plugin::TestPlugin;
    use Moo;
    with 'Gup::Role::Plugin';
    has test_argument => (
        is       => 'ro',
        required => 1,
    )
}

like(
    exception { Gup::Plugin::TestPlugin->new },
    qr/^Missing required arguments: gup/,
    'Gup::Role::Plugin requires a gup',
);

isa_ok(
    Gup::Plugin::TestPlugin->new(
        gup           => t::lib::Functions::create_test_gup,
        test_argument => undef
    ),
    'Gup::Plugin::TestPlugin'
);

my $gup = Gup->new(
    repo_dir     => t::lib::Functions::create_test_dir,
    plugins      => [ 'TestPlugin' ],
    plugins_args => {
        'TestPlugin' => {
            test_argument => 'test_argument_value',
        },
    },
);

my @plugins = $gup->find_plugins('-Plugin');

cmp_ok( @plugins, '==', 1, 'Found one plugin' );
isa_ok( $plugins[0], 'Gup::Plugin::TestPlugin' );
is($plugins[0]->test_argument,'test_argument_value','Plugin gets arguments');
