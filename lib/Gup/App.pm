use strict;
use warnings;
package Gup::App;

use Moo;
use Sub::Quote;

use Gup;
use Gup::Plugin::Sync::Rsync;
use Getopt::Long qw/:config no_ignore_case/;

has gup => (
    is     => 'ro',
    isa    => quote_sub( q{
        ref $_[0] and ref $_[0] eq 'Gup' or die "Incorrect gup object\n";
    } ),
    writer => 'set_gup',
);

sub run {
    my $self = shift;
    my %opts = ();

    GetOptions(
        # create new repo options
        'm|method=s'      => \$opts{'method'},
        'r|reposdir=s'    => \$opts{'repos_dir'},
        'c|config=s'      => \$opts{'configfile'},

        # rsync options
        'd|dir=s'         => \$opts{'dir'},
        'h|host=s'        => \$opts{'host'},
        'u|user=s'        => \$opts{'user'},
        'a|method_args=s' => \$opts{'args'},
    );

    # clean up the opts hash
    foreach my $key ( keys %opts ) {
        exists $opts{$key} && ! defined $opts{$key}
            and delete $opts{$key};
    }

    # get command and name
    my $command = shift @ARGV or die "Missing command to run\n";
    my $name    = shift @ARGV or die "Missing repo name\n";

    my $method = "command_$command";

    # try to find if it's an option attempt or non-existent command
    $command =~ /^-/    and die "Unknown option: $command\n";
    $self->can($method) or  die "Unknown command: $command\n";

    # create Gup object
    $opts{'name'} = $name;
    $self->set_gup( Gup->new(%opts) );

    exit $self->$method(%opts);
}

sub command_update {
    my $self = shift;
    my %opts = @_;

    print $self->gup->update_repo."\n";
    return 0;
}

sub command_new {
    my $self = shift;
    my %opts = @_;
    my $yaml = undef;
    
    my $configfile = $self->gup->configfile;
    my $repo_name  = $self->gup->name;
    my $repo_dir   = $self->gup->repo_dir;
    my $method     = $self->gup->method;

    # Rsync method argument that should be defined
    my %method_attributes = (
        args => '-ac',
        host => undef,
        user => undef,
        dir  => undef,
    );

    # Get arguments from user if his not define them
    foreach my $arg ( keys %method_attributes ) {
        $method_attributes{$arg} = $opts{$arg}
            if defined $opts{$arg};

        if( not defined $method_attributes{$arg} ) {
            print "$method $arg should be defined: ";
            chomp( my $input = <STDIN> );
            $input =~ s/^\s*//g;
            $input =~ s/\s*$//g;
            $method_attributes{$arg} = $input;
        }
    }

    # validate params
    Gup::Sync::Rsync->new( %method_attributes );

    # Write attributes to configfile
    ( -r $configfile and $yaml = YAML::Tiny->read( $configfile ) )
        or $yaml = YAML::Tiny->new;

    $yaml->[0]->{$repo_name}->{$method} = \%method_attributes;
    $yaml->write( $configfile ) or die "Can't write to configfile: $configfile";

    $self->gup->create_repo
        and print "Repo $repo_name successfully created at $repo_dir\n";
    return 0;
}

1;

