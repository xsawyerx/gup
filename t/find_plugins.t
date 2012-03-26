#!perl

use strict;
use warnings;

use Gup;
use Test::More tests => 3;

my $gup = Gup->new(
    name    => 'blah',
    plugins => ['Sync::Rsync'],
);

isa_ok( $gup, 'Gup' );

my @plugins = $gup->find_plugins('-Sync');

cmp_ok( @plugins, '==', 1, 'Found one plugin' );
isa_ok( $plugins[0], 'Gup::Plugin::Sync::Rsync' );

