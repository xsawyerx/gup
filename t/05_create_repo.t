use strict;
use warnings;
use Test::More  tests => 7;
use Test::File;
use t::lib::Functions;

use Gup;

my $dir = File::Spec->catdir( t::lib::Functions::create_test_dir, 'test_gup' );
my $gup = Gup->new( repo_dir => $dir );

$gup->create_repo;

isa_ok( $gup->repo, 'Git::Repository' );

my $file = t::lib::Functions::create_test_file($dir);

dir_exists_ok(
    $dir,
    'test repo dir exists',
);

dir_exists_ok(
    File::Spec->catdir( $dir, '.git' ),
    'test repo .git dir exists',
);

file_exists_ok( $file, "Repo test file $file created" );
file_contains_like( $file, qr/this is a test line/, 'Correct output' );

$gup->repo->run( 'add', $file );
$gup->repo->run( 'commit', '-m', 'test commit' );

my $output = $gup->repo->run('log');

like( $output, qr/Initial commit/, 'Correct initial commit' );
like( $output, qr/test commit/   , 'Correct test commit'    );

