use strict;
use warnings;
use Test::More;
use Test::Fatal;
use t::lib::Functions;

plan tests => 3;

use_ok( 'Gup' );

like(
    exception { Gup->new },
    qr/^Missing required arguments: repo_dir/,
    'Gup->new requires a repo_dir',
);

my $temp_dir = t::lib::Functions::create_test_dir();

isa_ok( Gup->new( repo_dir => $temp_dir ), 'Gup' );

done_testing;
