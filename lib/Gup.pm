use strict;
use warnings;
package Gup;

use Moo;
use Carp;
use YAML::Tiny;
use Sub::Quote;
use Git::Repository;
use System::Command;

use File::Path qw(mkpath);
use POSIX qw(strftime);

use Gup::Sync::Rsync;

has name => (
    is       => 'ro',
    isa      => quote_sub( q{
        $_[0] =~ /^(?:[A-Za-z0-9_-]|\.)+$/ or die "Improper repo name: '$_[0]'\n";
    } ),
    required => 1,
);

has method => (
    is      => 'ro',
    default => quote_sub(q{'rsync'}),
);

has configfile => (
    is      => 'ro',
    default => quote_sub(q{'/etc/gup/gup.yaml'}),
);

has repos_dir => (
    is      => 'ro',
    default => quote_sub(q{'/var/gup/repos'}),
);

has repo => (
    is        => 'ro',
    isa       => quote_sub( q{
        ref $_[0] and ref $_[0] eq 'Git::Repository'
            or die 'Repo must be a Git::Repository object'
    } ),
    writer    => 'set_repo',
    predicate => 'has_repo',
);

# TODO: allow to control the git user and email for this
# creates a new repository
sub create_repo {
    my $self     = shift;
    my $repo_dir = $self->repo_dir;

    # make sure it doesn't exist
    -d $repo_dir and croak "Repo dir '$repo_dir' already exists";

    # create it
    mkpath( $repo_dir ) or die "Can't mkdir $repo_dir: $!\n";

    # init new repo
    Git::Repository->run( init => $repo_dir );
    my $repo = Git::Repository->new( work_tree => $repo_dir );

    # create HEAD and first commit
    $repo->run( 'symbolic-ref', 'HEAD', 'refs/heads/master' );
    $repo->run( commit => '--allow-empty', '-m', 'Initial commit' );

    return $repo;
}

sub update_repo {
    my $self     = shift;
    my $repo_dir = $self->repo_dir;
    my $date     = strftime "%Y%m%d - %H:%M", localtime;

    chdir $repo_dir or die "Can't chdir to $repo_dir: $!\n";

    # sync directory
    $self->sync_dir;
    
    my $repo = Git::Repository->new( work_tree => '.' );

    # Try to add new files
    $repo->run( 'add', '-A' );

    # commit update
    return $repo->run( 'commit', '-a', '-m', "Update $date" );
}

#TODO: Make sync_dir per many methods
sub sync_dir {
    my $self  = shift;
    my $opts  = $self->get_sync_opts;
    my $rsync = Gup::Sync::Rsync->new( $opts );

    $rsync->sync_dir;
}

sub get_sync_opts {
    my $self       = shift;
    my $configfile = $self->configfile;
    my $repo_name  = $self->name;
    my $method     = $self->method;

    my $yaml = YAML::Tiny->read( $configfile )
        or die "Can't read configs file: $configfile";

    defined $yaml->[0]->{$repo_name}
        or die "There are no configs for repo '$repo_name'";

    defined $yaml->[0]->{$repo_name}->{$method}
        or die "There are no configs for method '$method'";

    return $yaml->[0]->{$repo_name}->{$method};
}

sub repo_dir {
    my $self = shift;
    return File::Spec->catdir( $self->repos_dir, $self->name );
}

1;

