use strict;
use warnings;
package Gup;

use Moo;
use Carp;
use Sub::Quote;
use Git::Repository;

has name => (
    is       => 'ro',
    isa      => quote_sub( q{
        $_[0] =~ /^(?:[A-Za-z0-9_-]|\.)+$/ or die "Improper name: '$_[0]'\n";
    } ),
    required => 1,
);

has dir => (
    is => 'ro',
);

has method => (
    is      => 'ro',
    default => quote_sub(q{'rsync'}),
);

has method_args => (
    is      => 'ro',
    default => quote_sub(q{'-az'}),
);

has configfile => (
    is      => 'ro',
    default => quote_sub(q{'/etc/gup/gup.yaml'}),
);

has conf_dir => (
    is      => 'ro',
    default => quote_sub(q{'/etc/gup'}),
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

# creates a new repository
sub create_repo {
    my $self     = shift;
    my $repo_dir = $self->repo_dir;

    # make sure it doesn't exist
    -d $repo_dir and croak "Repo dir '$repo_dir' already exists";

    # create it
    mkdir $repo_dir or die "Can't mkdir $repo_dir: $!\n";

    # init new repo
    Git::Repository->run( init      => $repo_dir );
    Git::Repository->new( work_tree => $repo_dir );
}

sub update_repo {
    my $self     = shift;
    my $repo_dir = $self->repo_dir;

    chdir $repo_dir or die "Can't chdir to $repo_dir: $!\n";

    # sync directory

    # commit update
    my $repo = Git::Repository->new( git_dir => './.git' );
}

sub repo_dir {
    my $self = shift;
    return File::Spec->catdir( $self->repos_dir, $self->name );
}

1;

