use strict;
use warnings;
package Gup::Plugin::Sync::Rsync;
# ABSTRACT: Rsync sync plugin for Gup

use Moo;
use Carp;
use Sub::Quote;
use System::Command;

# requires us to add sync() method which will be run
# XXX: for now provides username and host, which should be integrated here
with 'Gup::Role::Sync';

has args => (
    is      => 'ro',
    default => quote_sub(q{'-acz'}),
);

sub sync {
    my $self = shift;
    my $gup  = $self->gup;

    my ( $from, $to ) = @_;

    # TODO: move this into the Sync role and remove form here
    length $from && length $to
        or croak "sync( FROM, TO )";

    my $host = $self->host;
    my $user = $self->username;
    my $path = $host ? "$user\@$host:$from/" : "$from/";

    my $cmd  = System::Command->new(
        'rsync',
        $self->args,
        $path,
        $to,
        '--quiet',
        '--delete',
        '--exclude','.git',
    );
    $cmd->close;

    # return 1 for good, undef for rest
    # TODO: we don't really document the errors
    # should we call die/croak? should we return arrayref with it?
    # what about stdout vs. stderr? tricky stuff...
    return $cmd->exit == 0 ? 1 : undef;
}

1;

__END__

