#!perl

use strict;
use warnings;

use Gup;
use Test::More  tests => 10;
use File::Temp  'tempdir';
use Test::Fatal 'exception';
use Test::File;
use Git::Repository;

ok(
    exception { Gup->new },
    'Gup->new requires a name',
);

my $tempdir = tempdir( $ENV{'GUP_KEEPDIR'} ? () : ( CLEANUP => 1 ) );

my $gup = Gup->new( name => 'test', repos_dir => $tempdir );
isa_ok( $gup, 'Gup'         );
can_ok( $gup, 'create_repo' );

# get repo object and repo dir
my $repo     = $gup->create_repo;
my $repo_dir = $gup->repo_dir;

isa_ok( $repo, 'Git::Repository' );

dir_exists_ok(
    $repo_dir,
    'test repo dir exists',
);

dir_exists_ok(
    File::Spec->catdir( $repo_dir, '.git' ),
    'test repo .git dir exists',
);

my $testfile = File::Spec->catfile( $repo_dir, 'test.txt' );

# create a file with content, BAIL_OUT on tests if we don't succeed
open my $fh, '>', $testfile or BAIL_OUT("Can't open file: $!");
print {$fh} "this is a test line\n" or BAIL_OUT("Can't write to file: $!");
close $fh or BAIL_OUT("Can't close file: $!");

file_exists_ok( $testfile, "Repo test file $testfile created" );
file_contains_like( $testfile, qr/this is a test line/, 'Correct output' );

$repo->run( 'add', $testfile );
$repo->run( 'commit', '-m', 'test commit' );

my $output = $repo->run('log');

like( $output, qr/Initial commit/, 'Correct initial commit' );
like( $output, qr/test commit/   , 'Correct test commit'    );
