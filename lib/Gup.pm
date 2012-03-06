use strict;
use warnings;
package Gup;

use Moo;
use Carp;
use Try::Tiny;
use Sub::Quote;
use Git::Repository;
use System::Command;

use File::Path qw(mkpath);
use POSIX qw(strftime);

has name => (
    is       => 'ro',
    isa      => quote_sub( q{
        $_[0] =~ /^(?:[A-Za-z0-9_-]|\.)+$/ or die "Improper repo name: '$_[0]'\n";
    } ),
    required => 1,
);

has sync_class => (
    is      => 'ro',
    default => quote_sub(q{'Rsync'}),
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

has repo_dir => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_repo_dir',
);

has syncer => (
    is      => 'ro',
    isa     => quote_sub( q{
        ref( $_[0] ) and ref( $_[0] ) =~ /^\QGup::Sync::\E/
            or die 'Must be a Gup::Sync:: object'
    } ),
    lazy    => 1,
    builder => '_build_syncer',
);

has syncer_args => (
    is      => 'ro',
    isa     => quote_sub( q{
        ref $_[0] and ref $_[0] eq 'ARRAY'
            or die 'Must be arrayref'
    } ),
    default => quote_sub( q{[]} ),
);

sub _build_repo_dir {
    my $self = shift;
    return File::Spec->catdir( $self->repos_dir, $self->name );
};

sub _build_syncer {
    my $self  = shift;
    my $class = 'Gup::Sync::' . $self->sync_class;

    {
        local $@ = undef;
        eval "use $class";
        $@ and die "Can't load $class: $@\n";
    }

    return $class->new( @{ $self->syncer_args } );
}

sub sync {
    my $self = shift;
    my $from = shift;

    return $self->syncer->sync( $from, $self->repo_dir );
}

# TODO: allow to control the git user and email for this
# creates a new repository
sub create_repo {
    my $self     = shift;
    my $repo_dir = $self->repo_dir;

    # make sure it doesn't exist
    -d $repo_dir and croak "Repo dir '$repo_dir' already exists";

    # create it
    mkpath($repo_dir) or croak "Can't mkdir $repo_dir: $!\n";

    # init new repo
    Git::Repository->run( init => $repo_dir );
    my $repo = Git::Repository->new( work_tree => $repo_dir );

    $repo->run( 'config', '--local', 'user.email', 'you@example.com' );
    $repo->run( 'config', '--local', 'user.name', 'Your Name' );

    # create HEAD and first commit
    $repo->run( 'symbolic-ref', 'HEAD', 'refs/heads/master' );
    $repo->run( commit => '--allow-empty', '-m', 'Initial commit' );

    $self->set_repo($repo);

    return $repo;
}

sub update_repo {
    my $self = shift;

    # Sync repo before
    defined $self->sync_repo( @_ ) or croak 'There was error on sync repo';
    
    # Commit updates
    return $self->commit_updates( @_ );
}

sub commit_updates {
    my $self = shift;

    @_ % 2 == 0 or croak 'commit_updates() gets a hash as parameter';

    my %opts    = @_ ;
    my $message = defined $opts{'message'} ?
                  $opts{'message'}         :
                  'Gup commit: ' . strftime "%Y%m%d - %H:%M", localtime;

    my $repo = $self->repo;

    # add all
    $repo->run( 'add', '-A' );

    # commit update
    return $self->repo->run( 'commit', '-a', '-m', $message );
}

sub sync_repo {
    my $self     = shift;

    @_ % 2 == 0 or croak 'sync_repo() gets a hash as parameter';

    my %opts     = @_;
    my $repo_dir = $self->repo_dir;
    my $sync_dir = $opts{sync_from};

    chdir $repo_dir or die "Can't chdir to $repo_dir: $!\n";

    # sync directory
    return $self->syncer->sync( $sync_dir , $repo_dir );
}

1;

