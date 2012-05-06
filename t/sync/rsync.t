use strict;
use warnings;

use Test::More  tests => 11;
use Test::Fatal 'exception';
use Test::File; # dir_exists, etc.
use t::lib::Functions; # create_test_{dir,file}

use File::Basename;
use Gup::Plugin::Sync::Rsync;

my $to   = t::lib::Functions::create_test_dir;
my $from = t::lib::Functions::create_test_dir;
my $gup  = t::lib::Functions::create_test_gup($to);

like(
    exception { Gup::Plugin::Sync::Rsync->new },
    qr/^Missing required arguments: gup/,
    'gup should be defined for sync plugin',
);

like(
    exception { Gup::Plugin::Sync::Rsync->new( gup => $gup ) },
    qr/^Missing required arguments: source_dir/,
    'shource dir should be defined for sync plugin',
);

my $rsync = Gup::Plugin::Sync::Rsync->new(
    source_dir => $from,
    gup        => $gup,
);

isa_ok( $rsync, 'Gup::Plugin::Sync::Rsync' );

# create a file in $from directory
my $file = t::lib::Functions::create_test_file($from);

diag( $file );

file_exists_ok(    $file, "Created file $file" );
file_not_empty_ok( $file, 'It is not empty'    );

file_contains_like(
    $file,
    qr/this is a test line/,
    'Correct output',
);

can_ok( $rsync, 'sync' );
ok( $rsync->sync, 'sync method successful' );

my $filename = basename $file;
my $newfile  = File::Spec->catfile( $to, $filename );

file_exists_ok( $newfile, "$filename was synced from $from to $to" );
file_not_empty_ok( $newfile, 'It is not empty' );

file_contains_like(
    $newfile,
    qr/this is a test line/,
    'Correct output',
);
