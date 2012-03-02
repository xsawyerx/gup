#!/usr/bin/perl
use warnings;
use strict;

use Gup;
use YAML::Tiny;

use Test::More tests => 16;
use Test::File;

use File::Temp qw/tempdir tempfile/;

my $repo_name            = 'test_update_rsync';
my $temp_repos_dir       = tempdir( CLEANUP => 1 ); 
my $temp_rsync_dir       = tempdir( CLEANUP => 1 ); 
my ( $cfh, $configfile ) = tempfile();

my $yaml = YAML::Tiny->new;
$yaml->[0]->{$repo_name}->{rsync}->{host} = '';
$yaml->[0]->{$repo_name}->{rsync}->{user} = '';
$yaml->[0]->{$repo_name}->{rsync}->{dir}  = "$temp_rsync_dir";
$yaml->write( $configfile );

my $gup = Gup->new(
    name       => $repo_name,
    repos_dir  => "$temp_repos_dir",
    configfile => $configfile,
);

isa_ok( $gup, 'Gup' );
can_ok( $gup, qw/update_repo/ );

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

# Creating new file on remote directory
my $testfile = File::Spec->catfile( $temp_rsync_dir, 'test_update_rsync.txt' );

open my $fh, '>', $testfile or BAIL_OUT("Can't open file: $!");
print {$fh} "Test file for rsync test\n" or BAIL_OUT("Can't write to file: $!");
close $fh or BAIL_OUT("Can't close file: $!");
file_contains_like( $testfile, qr/rsync test/, 'Correct output' );

my $output = $gup->update_repo;

like( $output, qr/Update \d{8} - \d\d:\d\d/, 'Check commit' );
like( $output, qr/1 files changed, 1 insertions\(\+\), 0 deletions\(-\)/, 'Check create' );
like( $output, qr/create mode \d+ test_update_rsync.txt/, 'Testfile added and commited' );

open $fh, '>>', $testfile or BAIL_OUT("Can't open file: $!");
print {$fh} "Added some text\n" or BAIL_OUT("Can't write to file: $!");
close $fh or BAIL_OUT("Can't close file: $!");
file_contains_like( $testfile, qr/some text/, 'Correct output' );

$output = $gup->update_repo;

like( $output, qr/Update \d{8} - \d\d:\d\d/, 'Check commit' );
like( $output, qr/1 files changed, 1 insertions\(\+\), 0 deletions\(-\)/, 'Check update' );

unlink $testfile;
file_not_exists_ok( $testfile );

$output = $gup->update_repo;

like( $output, qr/Update \d{8} - \d\d:\d\d/, 'Check commit' );
like( $output, qr/1 files changed, 0 insertions\(\+\), 2 deletions\(-\)/, 'Check delete' );
like( $output, qr/delete mode \d+ test_update_rsync.txt/, 'Testfile deleted and commited' );

chdir '/tmp';
