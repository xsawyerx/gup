use strict;
use warnings;
use Test::More  tests => 7;
use Test::File;
use t::lib::Functions;

use File::Copy;
use File::Basename;

use Gup;

# this is basically t/create_repo.t
# then we'll add extra stuff and try to commit the updates
# my $dir = t::lib::Functions::create_test_dir;
# my $gup = Gup->new( name => 'test', repos_dir => $dir );

my $gup_dir = t::lib::Functions::create_test_dir;
my $gup     = t::lib::Functions::create_test_gup( $gup_dir.'test' );

# get repo object and repo dir
$gup->create_repo;

my $file = t::lib::Functions::create_test_file($gup->repo_dir);

# now creating a new file
# and asking gup to update the repo
can_ok( $gup, 'commit_updates' );

$gup->commit_updates(
    message => 'this is my test commit',
);

my $output = $gup->repo->run('log');

like( $output, qr/Initial commit/, 'Correct initial commit' );

my $newfile = File::Spec->catfile( dirname($file), 'bgzzz' );
copy( $file, $newfile );
file_exists_ok( $newfile, "Create new file: $newfile" );
file_contains_like( $newfile, qr/this is a test line/, 'Correct output' );

$gup->commit_updates();

$output = $gup->repo->run('log');

like( $output, qr/Initial commit/,          'Correct initial commit' );
like( $output, qr/this is my test commit/ , 'Correct test commit'    );
like( $output, qr/\QGup commit:\E/,         'Got Gup commit!'        );

