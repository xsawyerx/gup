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
      $_[0] =~ /^(?:[A-Za-z0-9_-]|\.)+$/ or die "Improper repo name: '$_[0]'\n"
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
            or die 'repo must be a Git::Repository object'
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
            or die 'syncer must be a Gup::Sync:: object'
    } ),
    lazy    => 1,
    builder => '_build_syncer',
);

has syncer_args => (
    is      => 'ro',
    isa     => quote_sub( q{
        ref $_[0] and ref $_[0] eq 'ARRAY'
            or die 'syncer_args must be an arrayref'
    } ),
    default => quote_sub( q{[]} ),
);

has source_dir => (
    is        => 'ro',
    isa       => quote_sub( q{
        defined $_[0] and length $_[0] > 0
            or die 'source_dir must be provided'
    } ),
    predicate => 'has_source_dir',
);

has plugins => (
    is      => 'ro',
    isa     => quote_sub( q{
        ref $_[0] and ref $_[0] eq 'ARRAY'
            or die 'plugins must be an arrayref'
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
        $@ and croak "Can't load $class: $@";
    }

    return $class->new( @{ $self->syncer_args } );
}

sub BUILD {
    my $self = shift;

    foreach my $plugin ( @{ $self->plugins } ) {
        eval "use $plugin";
    }
}

sub sync_repo {
    my $self = shift;

    $self->has_source_dir or croak 'Must provide a source_dir';

    # find all plugins that use a role Sync
    # then run it
    # TODO: add BeforeSync, AfterSync
    foreach my $plugin ( $self->find_plugins('-Sync' ) ) {
        $plugin->new( gup => $self )
               ->sync( $self->source_dir, $self->repo_dir );
    }
}

sub find_plugins {
    my $self = shift;
    my $role = shift;

    $role =~ s/^-/Gup::Role::/;

    return grep { $_->does($role) } @{ $self->plugins };
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
    $self->sync_repo or croak 'sync_repo failed';
    
    # Commit updates
    return $self->commit_updates(@_);
}

sub commit_updates {
    my $self = shift;

    @_ % 2 == 0 or croak 'commit_updates() gets a hash as parameter';

    my %opts    = @_ ;
    my $message = defined $opts{'message'} ?
                  $opts{'message'}         :
                  'Gup commit: ' . strftime "%Y/%m/%d - %H:%M", localtime;

    my $repo = $self->repo;

    # add all
    $repo->run( 'add', '-A' );

    # commit update
    return $self->repo->run( 'commit', '-a', '-m', $message );
}

1;

