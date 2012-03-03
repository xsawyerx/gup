use warnings;
use strict;
package Gup::Sync;
use Moo;
use YAML::Tiny;

sub new_from_configfile {
    my $self       = shift;
    my $gup        = shift;
    my $configfile = $gup->configfile;
    my $repo_name  = $gup->name;
    my $method     = $gup->method;

    my $yaml = YAML::Tiny->read( $configfile )
        or die "Can't read configfile: $configfile";

    defined $yaml->[0]->{$repo_name}
        or die "There are no configs for repo '$repo_name'";

    defined $yaml->[0]->{$repo_name}->{$method}
        or die "There are no configs for method '$method'";

    return $self->new( $yaml->[0]->{$repo_name}->{$method} );
}

sub sync_dir {
    die "sync_dir not implemented yet!";
}

1;
