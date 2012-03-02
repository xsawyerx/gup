use strict;
use warnings;
package Gup::Sync::Rsync;

use Moo;
use Sub::Quote;

has host => (
    is       => 'ro',
    isa      => quote_sub( q{
        $_[0] =~ /^(?:[A-Za-z0-9_-]|\.)+$/ or die "Improper host: '$_[0]'\n";
    } ),
    required => 1,
);

has user => (
    is       => 'ro',
    isa      => quote_sub( q{
        $_[0] =~ /^(?:[A-Za-z0-9_-]|\.)+$/ or die "Improper user: '$_[0]'\n";
    } ),
    required => 1,
);

has dir => (
    is       => 'ro',
    isa      => quote_sub( q{
        $_[0] =~ /^(?:[A-Za-z0-9_-]|\.|\/)+$/ or die "Improper dir: '$_[0]'\n";
    } ),
    required => 1,
);

sub sync_dir {
    my $self = shift;
    my $host = $self->host;
    my $user = $self->user;
    my $dir  = $self->dir;

    # currently we hardcode rsync
    my $cmd = System::Command->new(
        'rsync',
        '-avc', '--quiet',
        "$user\@$host:$dir/",'.'
    );
}

1;

