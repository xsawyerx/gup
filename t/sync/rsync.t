#!perl

use strict;
use warnings;

use Test::More  tests => 8;
use Test::Fatal 'exception';
use Test::File; # dir_exists, etc.
use t::lib::Functions; # create_test_{dir,file}

use File::Basename;
use Gup::Sync::Rsync;

my $rsync = Gup::Sync::Rsync->new;
isa_ok( $rsync, 'Gup::sync::Rsync' );

my $from = t::lib::Functions::create_test_dir;
my $to   = t::lib::Functions::create_test_dir;

# create a file in $from directory
my $file = t::lib::Functions::create_test_file($from);

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
my $new_file = File::Spec->catfile( $to, $filename );

file_exists_ok( $newfile, "$filename was synced to $to ($new_file)" );
file_not_empty_ok( $newfile, 'It is not empty' );

file_contains_like(
    $newfile,
    qr/this is a test line/,
    'Correct output',
);

