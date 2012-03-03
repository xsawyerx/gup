#!perl

use strict;
use warnings;

use Gup;
use Test::More tests => 2;
use Test::Fatal;

ok(
    exception { Gup->new },
    'Gup->new requires a name',
);

is(
    exception { Gup->new( name => 'test' ) },
    undef,
    'Gup->new with name works',
);

