use strict;
use warnings;
package Gup::Plugin::Sync::Mysql;
# ABSTRACT: Mysql sync plugin for Gup

use Moo;
use Carp;
use Sub::Quote;
use MooX::Types::MooseLike::Base qw/Str/;
use System::Command;

with 'Gup::Role::Sync';
with 'Gup::Role::BeforeSync';

has mysqldump_path => (
    is        => 'ro',
    isa       => Str,
    default   => quote_sub(q{'/usr/bin/mysqldump'}),
);

has mysqldump_user => (
    is        => 'ro',
    isa       => Str,
    predicate => 'has_mysqldump_user',
);

has mysqldump_password => (
    is        => 'ro',
    isa       => Str,
    predicate => 'has_mysqldump_password',
);

has mysqldump_databases => (
    is        => 'ro',
    isa       => Str,
    predicate => 'has_mysqldump_databases',
);

has mysqldump_args => (
    is        => 'ro',
    isa       => Str,
    predicate => 'has_mysqldump_args',
);

has remote_dump_path => (
    is        => 'ro',
    isa       => Str,
    default   => quote_sub(q{'dump.sql'}),
);

has user_at_host => (
    is        => 'ro',
    isa       => Str,
    lazy      => 1,
    builder   => '_build_user_at_host',
);

sub _build_user_at_host {
    my $self = shift;
    my $host = $self->host;
    my $user = $self->username;

    $self->has_host ? "$user\@$host" : '';
}

sub before_sync {
    my $self      = shift;
    my $from      = shift;
    my $to        = shift;
    my $scp       = $self->scp_path;
    my $ssh       = $self->ssh_path;
    my $host      = $self->user_at_host;
    my $rpath     = $from.'/'.$self->remote_dump_path;
    my $mysqldump = $self->mysqldump_path;
    my $args      = $self->has_mysqldump_args ?
                    $self->mysqldump_args : '';
    my $user      = $self->has_mysqldump_user ?
                    '-u '.$self->mysqldump_user : '';
    my $password  = $self->has_mysqldump_password ?
                    '-p'.$self->mysqldump_password : '';
    my $databases = $self->has_mysqldump_databases ?
                    '--databases '.$self->mysqldump_databases : '';

    my $mysqldump_cmd = sprintf("%s %s %s %s %s > %s",
        $mysqldump, $user, $password, $databases, $args, $rpath );

    #TODO: Get full log on error also from file. ( stdout going to file )
    my $cmd = System::Command->new( $self->ssh_path, $host, $mysqldump_cmd );
    $cmd->close;
    $cmd->exit == 0 or die "Cmd: '$mysqldump_cmd' failed on mysql sync";
}

sub sync {
    my $self  = shift;
    my $from  = shift;
    my $to    = shift;
    my $rpath = $self->remote_dump_path;
    my $path  = $self->user_at_host ne '' ?
                $self->user_at_host.":$from/$rpath" : "$from/$rpath";
    my $cmd   = System::Command->new( $self->scp_path, $path, $to );
    $cmd->_reap;
    $cmd->exit == 0
        or die "Failed to sync mysql:\n".join("\n",$cmd->stderr->getlines);
    $cmd->close;
}

1;

__END__

