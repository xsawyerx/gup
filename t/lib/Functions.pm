use strict;
use warnings;
package t::lib::Functions;

use File::Spec;
use File::Temp;

sub create_test_gup {
    my $temp_dir = shift // create_test_dir();

    require Gup;
    Gup->new( repo_dir => $temp_dir );
}

sub create_test_dir {
    my $dir = shift;

    File::Temp::tempdir(
        DIR     => $dir,
        CLEANUP => not $ENV{GUP_KEEP_TEST_DIR},
    );
}

sub create_test_file {
    my $dir = shift;

    # create a file with content, BAIL_OUT on tests if we don't succeed
    my $file = File::Spec->catfile( $dir, 'test.txt' );
    open my $fh, '>', $file or BAIL_OUT("Can't open file: $!");
    print {$fh} "this is a test line\n" or BAIL_OUT("Can't write to file: $!");
    close $fh or BAIL_OUT("Can't close file: $!");

    return $file;
}

1;

