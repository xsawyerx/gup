use strict;
use warnings;
package Gup::Sync::Rsync;
# ABSTRACT: Rsync sync method for Gup

use Moo;
use Carp;
use Sub::Quote;
use System::Command;

with 'Gup::Role::Syncer';

has args => (
    is      => 'ro',
    default => quote_sub(q{'-acz'}),
);

sub sync {
    my $self          = shift;
    my ( $from, $to ) = @_;

    length $from && length $to
        or croak "sync( FROM, TO )";
    my $host = $self->host;
    my $user = $self->username;

    my $cmd = System::Command->new(
        'rsync',
        $self->args,
        "$user\@$host:$from/",
        $to,
    );

    # finish
    $cmd->close;

    # return 1 for good, undef for rest
    # TODO: we don't really document the errors
    # should we call die/croak? should we return arrayref with it?
    # what about stdout vs. stderr? tricky stuff...
    return $cmd->exit == 0 ? 1 : undef;
}

1;

__END__

