use strict;
use warnings;
package Gup::Plugin::Sync::Rsync;
# ABSTRACT: Rsync sync plugin for Gup

use Moo;
use Carp;
use Sub::Quote;
use System::Command;
use MooX::Types::MooseLike::Base qw/Str/;

# requires us to add sync() method which will be run
# XXX: for now provides username and host, which should be integrated here
with 'Gup::Role::Sync';
with 'Gup::Role::SSHAuth';

has source_dir => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has rsync_path => (
    is      => 'ro',
    isa     => Str,
    default => quote_sub( q{'/usr/bin/rsync'} ),
);

has rsync_args => (
    is      => 'ro',
    isa     => Str,
    default => quote_sub(q{'-acz'}),
);

sub sync {
    my $self  = shift;
    my $gup   = $self->{gup}; # TODO: Fix this
    my $to    = $gup->repo_dir;
    my $from  = $self->source_dir;
    my $rpath = $self->get_auth_path($from);
    my $cmd   = System::Command->new(
        $self->rsync_path,
        $self->rsync_args,
        $rpath,
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

