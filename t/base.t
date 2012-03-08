#!perl

use strict;
use warnings;

use Gup;
use Test::More tests => 2;
use Test::Fatal;

like(
    exception { Gup->new },
    qr/^Missing required arguments: name/,
    'Gup->new requires a name',
);

is(
    exception { Gup->new( name => 'test' ) },
    undef,
    'Gup->new with name works',
);

