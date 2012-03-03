#!perl

use strict;
use warnings;

use Test::More  tests => 13;
use Test::Fatal 'exception';
use Test::File; # dir_exists, etc.
use t::lib::Functions; # create_test_{dir,file}

use File::Basename;
use Gup::Sync::Rsync;

my $rsync;
is(
    exception { $rsync = Gup::Sync::Rsync->new },
    undef,
    'Can create sync with host',
);

isa_ok( $rsync, 'Gup::Sync::Rsync' );

my $from = t::lib::Functions::create_test_dir;
my $to   = t::lib::Functions::create_test_dir;

dir_exists_ok( $from, "From dir ($from) exists" );
dir_exists_ok( $to,   "From dir ($to) exists"   );

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

like(
    exception { $rsync->sync },
    qr/^\Qsync( FROM, TO )\E/,
    'Fails with missing arguments to sync()',
);

ok( $rsync->sync( $from, $to ), 'sync method successful' );

my $filename = basename $file;
my $newfile  = File::Spec->catfile( $to, $filename );

file_exists_ok( $newfile, "$filename was synced to $to ($newfile)" );
file_not_empty_ok( $newfile, 'It is not empty' );

file_contains_like(
    $newfile,
    qr/this is a test line/,
    'Correct output',
);

