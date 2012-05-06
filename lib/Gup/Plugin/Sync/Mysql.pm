use strict;
use warnings;
package Gup::Plugin::Sync::Mysql;
# ABSTRACT: Mysql sync plugin for Gup

use Moo;
use Carp;
use Sub::Quote;
use MooX::Types::MooseLike::Base qw/Str/;
use System::Command;
use File::Spec;

with 'Gup::Role::Sync';
with 'Gup::Role::SSHAuth';
with 'Gup::Role::BeforeSync';

has mysqldump_path => (
    is        => 'ro',
    isa       => Str,
    default   => quote_sub(q{'/usr/bin/mysqldump'}),
);

has mysqldump_file => (
    is        => 'ro',
    isa       => Str,
    default   => quote_sub(q{'/tmp/dump.sql'}),
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

sub before_sync {
    my $self      = shift;
    my $rhost     = $self->auth_host;
    my $rpath     = $self->mysqldump_file;
    my $mysqldump = $self->mysqldump_path;
    my $args      = $self->has_mysqldump_args ?
                    $self->mysqldump_args : '';
    my $user      = $self->has_mysqldump_user ?
                    '-u '.$self->mysqldump_user : '';
    my $password  = $self->has_mysqldump_password ?
                    '-p'.$self->mysqldump_password : '';
    my $databases = $self->has_mysqldump_databases ?
                    '--databases '.$self->mysqldump_databases : '';

    # Build mysqldump command to run on remote server
    my $mysqldump_cmd = sprintf("%s %s %s %s %s > %s",
        $mysqldump, $user, $password, $databases, $args, $rpath );

    # Run mysqldump command on remote server
    my $cmd = System::Command->new( $self->ssh_path, $rhost, $mysqldump_cmd );
    $cmd->close;
    $cmd->exit == 0 or die "Cmd: '$mysqldump_cmd' failed on mysql sync";
}

sub sync {
    my $self  = shift;
    my $to    = $self->{gup}->repo_dir;
    my $from  = $self->mysqldump_file;
    my $rpath = $self->get_auth_path($from);
    my $cmd   = System::Command->new( $self->scp_path, $rpath, $to );

    $cmd->_reap;
    $cmd->exit == 0 or die "Failed to sync mysql 'scp $rpath $to'";
    $cmd->close;
}

1;

__END__

