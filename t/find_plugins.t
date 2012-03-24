#!perl

use strict;
use warnings;

use Gup;
use Test::More tests => 2;

my $gup = Gup->new(
    name    => 'blah',
    plugins => ['Gup::Plugin::Sync::Rsync'],
);

isa_ok( $gup, 'Gup' );

my @plugins = $gup->find_plugins('-Sync');

is_deeply(
    \@plugins,
    ['Gup::Plugin::Sync::Rsync'],
    'find_plugins works',
);
