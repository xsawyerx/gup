#!perl

use strict;
use warnings;

use Gup;
use Test::More tests => 3;
use Test::Fatal;

like(
    exception { Gup->new },
    qr/^Missing required arguments: name/,
    'Gup->new requires a name',
);

like(
    exception { Gup->new( name => 'test' ) },
    qr/^Missing required arguments: source_dir/,
    'Gup->new with name works',
);

is(
    exception { Gup->new( name => 'test', source_dir => 'test' ) },
    undef,
    'Gup->new with name works',
);
