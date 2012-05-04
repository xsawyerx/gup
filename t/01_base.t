use strict;
use warnings;
use Test::More tests => 3;
use Test::Fatal;
use t::lib::Functions;

use_ok( 'Gup' );

like(
    exception { Gup->new },
    qr/^Missing required arguments: repo_dir/,
    'Gup->new requires a repo_dir',
);

my $temp_dir = t::lib::Functions::create_test_dir();

isa_ok( Gup->new( repo_dir => $temp_dir ), 'Gup' );
