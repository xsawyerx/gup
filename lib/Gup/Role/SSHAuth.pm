use strict;
use warnings;
package Gup::Role::SSHAuth;
# ABSTRACT: Auth role for syncer's use

use English '-no_match_vars';
use Moo::Role;
use Sub::Quote;
use MooX::Types::MooseLike::Base qw/Str/;

has host      => (
    is        => 'ro',
    isa       => quote_sub( q{
        $_[0] =~ /^(?:[A-Za-z0-9_-]|\.)+$/ or die "Improper host: '$_[0]'\n";
    } ),
    predicate => 'has_host',
);

has username  => (
    is        => 'ro',
    isa       => quote_sub( q{
        $_[0] =~ /^(?:[A-Za-z0-9_-]|\.)*$/ or die "Improper user: '$_[0]'\n";
    } ),
    builder   => '_build_username',
);

has auth_host => (
    is        => 'ro',
    isa       => Str,
    lazy      => 1,
    builder   => '_build_auth_host',
);

sub get_auth_path {
    my $self = shift;
    my $path = shift;

    defined $path or die "\$path should be defined";

    $self->auth_host ne '' ? $self->auth_host.':'.$path : $path;
}

sub _build_username { getpwuid $REAL_USER_ID; }

sub _build_auth_host {
    my $self = shift;
    my $host = $self->host;
    my $user = $self->username;

    $self->has_host ? "$user\@$host" : '';
}

1;

__END__
