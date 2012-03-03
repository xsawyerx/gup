#!perl

use strict;
use warnings;

use Gup;
use Test::More  tests => 9;
use Test::Fatal 'exception';
use Test::File;
use t::lib::Functions;

# this is basically t/create_repo.t
# then we'll add extra stuff and try to commit the updates
my $dir = t::lib::Functions::create_test_dir;
my $gup = Gup->new( name => 'test', repos_dir => $dir );

isa_ok( $gup, 'Gup'         );
can_ok( $gup, 'create_repo' );

# get repo object and repo dir
my $repo     = $gup->create_repo;
my $repo_dir = $gup->repo_dir;

isa_ok( $repo, 'Git::Repository' );

my $file = t::lib::Functions::create_test_file($repo_dir);
diag("Created temp dir $dir");

dir_exists_ok(
    $repo_dir,
    'test repo dir exists',
);

dir_exists_ok(
    File::Spec->catdir( $repo_dir, '.git' ),
    'test repo .git dir exists',
);

file_exists_ok( $file, "Repo test file $file created" );
file_contains_like( $file, qr/this is a test line/, 'Correct output' );

# now creating a new file
# and asking gup to update the repo
can_ok( $gup, 'commit_updates' );

$gup->commit_updates(
    message => 'this is my test commit',
);

my $output = $repo->run('log');

like( $output, qr/Initial commit/,          'Correct initial commit' );
like( $output, qr/this is my test commit/ , 'Correct test commit'    );

