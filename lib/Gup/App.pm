use strict;
use warnings;
package Gup::App;

use Moo;
use Sub::Quote;

use Gup;
use Getopt::Long qw/:config no_ignore_case/;

has gup => (
    is     => 'ro',
    isa    => quote_sub( q{
        ref $_[0] and ref $_[0] eq 'Gup' or die "Incorrect gup object\n";
    } ),
    writer => 'set_gup',
);

sub parse_args {
    my $self = shift;
    my %opts = ();

    GetOptions(
        'd|dir=s'       => \$opts{'dir'},
        'h|host=s'      => \$opts{'host'},
        'p|port=s'      => \$opts{'port'},
        'repodir=s'     => \$opts{'repo_dir'},
        'm|method=s'    => \$opts{'method'},
        'method-args=s' => \$opts{'method_args'},
        'confdir=s'     => \$opts{'conf_dir'},
        'repodir=s'     => \$opts{'repo_dir'},
        'c|config=s'    => \$opts{'configfile'},
    );

    @ARGV      or die "Missing command to run\n";
    @ARGV == 2 or die "Too many arguments\n";

    # clean up the opts hash
    foreach my $key ( keys %opts ) {
        exists $opts{$key} && ! defined $opts{$key}
            and delete $opts{$key};
    }

    # get command and name
    my ( $command, $name ) = @ARGV;
    my $method = "command_$command";

    # try to find if it's an option attempt or non-existent command
    $command =~ /^-/    and die "Unknown option: $command\n";
    $self->can($method) or  die "Unknown command: $command\n";

    # create Gup object
    $opts{'name'} = $name;

    $self->set_gup( Gup->new(%opts) );

    return $self->$method(%opts);
}

sub run {
    my $self = shift;
    $self->parse_args;
}

sub command_new {
    my $self = shift;
    my %opts = @_;

    # check that all attributes exist
    if ( ! defined $opts{'host'} ) {
        print 'host: ';
        chomp( my $input = <STDIN> );

        $input =~ s/^\s*//g;
        $input =~ s/\s*$//g;
        $input or die "Must provide a host\n";
        $input =~ /^(?:[A-Za-z0-9_-]|\.)+$/ or die "Improper host name\n";

        $opts{'host'} = $input;
    }

    $self->gup->create_repo;
}

1;

