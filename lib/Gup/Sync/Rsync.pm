use strict;
use warnings;
package Gup::Sync::Rsync;

use Moo;

sub sync_dir {
    my $self = shift;
    my $host = $self->host;
    my $user = $self->user;
    my $dir  = $self->dir;

    # currently we hardcode rsync
    my $cmd = System::Command->new(
        'rsync',
        '-avc', '--quiet',
        "$user\@$host:$dir",
    );
}

1;

