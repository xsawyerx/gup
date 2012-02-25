#!perl

use strict;
use warnings;

use Gup;
use Test::More  tests => 6;
use File::Temp  'tempdir';
use Test::Fatal 'exception';
use Test::File;
use Git::Repository;

ok(
    exception { Gup->new },
    'Gup->new requires a name',
);

my $tempdir = tempdir( $ENV{'GUP_KEEPDIR'} ? () : ( CLEANUP => 1 ) );

my $gup = Gup->new( name => 'test', main_repo_dir => $tempdir );
isa_ok( $gup, 'Gup' );

$gup->create_repo;
my $repo_dir = $gup->repo_dir;

dir_exists_ok(
    $repo_dir,
    'test repo dir exists',
);

dir_exists_ok(
    File::Spec->catdir( $repo_dir, '.git' ),
    'test repo .git dir exists',
);

my $repo     = Git::Repository->new( work_tree => $repo_dir );
my $testfile = File::Spec->catfile( $repo_dir, 'test.txt' );
open my $fh, '>', $testfile or BAIL_OUT("Can't open file: $!");
print {$fh} "this is a test line\n" or BAIL_OUT("Can't write to file: $!");
close $fh or BAIL_OUT("Can't close file: $!");

file_exists_ok( $testfile, "Repo test file $testfile created" );
file_contains_like( $testfile, qr/this is a test line/, 'Correct output' );

$repo->run( 'commit', '-m', 'test commit' );
my $output = $repo->run('log');

