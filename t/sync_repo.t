#!perl

use strict;
use warnings;

use Gup;
use Test::More  tests => 16;
use Test::Fatal 'exception';
use Test::File;
use t::lib::Functions;

use File::Copy;
use File::Path;
use File::Basename;

# this is basically t/create_repo.t
# then we'll add extra stuff and try to commit the updates
my $repos_dir = t::lib::Functions::create_test_dir;
my $gup       = Gup->new( name => 'test', repos_dir => $repos_dir );

# get repo object and repo dir
my $repo     = $gup->create_repo;
my $repo_dir = $gup->repo_dir;

my $sync_from_dir = t::lib::Functions::create_test_dir;

dir_exists_ok( $sync_from_dir, 'Sync from dir' );

my $sync_file = t::lib::Functions::create_test_file($sync_from_dir);

file_exists_ok( $sync_file, "Sync test file $sync_file created" );
file_contains_like( $sync_file, qr/this is a test line/, 'Correct output' );

# sync directories
can_ok( $gup, 'sync_repo' );
$gup->sync_repo( sync_from => $sync_from_dir );

# check sync of the dir
my $synced_file = File::Spec->catfile( $repo_dir, basename( $sync_file ) );
file_exists_ok( $synced_file, 'Succesfully synced ( added ) file' );

unlink $synced_file;

my $sync_dir    = t::lib::Functions::create_test_dir( $sync_from_dir );
my $sync_file_2 = t::lib::Functions::create_test_file( $sync_dir );

dir_exists_ok( $sync_dir, 'Creation new test dir in sync from dir' );
file_exists_ok( $sync_file_2, 'Test 2 file creations' );
file_contains_like( $sync_file_2, qr/this is a test line/, 'Correct output' );

# sync directories
$gup->sync_repo( sync_from => $sync_from_dir );

my $synced_dir = File::Spec->catdir( $repo_dir, basename( $sync_dir ) );
my $synced_file_2 = File::Spec->catfile( $synced_dir, basename( $sync_file_2 ) );

file_exists_ok( $synced_file, 'Returned removed file successfully' );
dir_exists_ok( $synced_dir, 'Dir successfully synced' );
file_exists_ok( $synced_file_2, 'File in the dir also synced' );
file_contains_like( $synced_file_2,  qr/this is a test line/, 'Correct text' ); 

unlink $sync_file;
unlink $sync_file_2;
rmtree $sync_dir;

$gup->sync_repo( sync_from => $sync_from_dir );

file_not_exists_ok( $synced_file, 'File successfully deleted' );
ok(
    ( ( ! -e $synced_dir ) && ( ! -d $synced_dir ) ),
    'Dir successfully deleted',
);
file_not_exists_ok( $synced_file_2, 'File successfully deleted' );

my $git_dir = File::Spec->catdir( $repo_dir, '.git' );

dir_exists_ok( $git_dir, 'Git dir not removed' ); 

chdir '/tmp';
