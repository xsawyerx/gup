use strict;
use warnings;
package t::lib::Functions;

use File::Spec;
use File::Temp;

sub create_test_dir {
    my $dir = shift;

    # create a directory
    my $test_dir = File::Temp::tempdir(
        DIR => $dir,
        $ENV{'GUP_KEEPDIR'} ? () : ( CLEANUP => 1 ),
    );

    return $test_dir;
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

