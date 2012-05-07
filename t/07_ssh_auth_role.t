use strict;
use warnings;
use Test::More tests => 11;
use Test::Fatal;
use t::lib::Functions;

use English '-no_match_vars';

use_ok( 'Gup::Role::SSHAuth' );

{
    package Gup::TestSSHAuth;
    use Moo;
    with 'Gup::Role::SSHAuth';
    sub sync{}
}

my $auth = Gup::TestSSHAuth->new;

can_ok( $auth, qw( auth_host get_auth_path ) );

like(
    exception {$auth->get_auth_path },
    qr/^\$path should be defined/,
    '$path should be defined for get_auth_path',
);

is( $auth->auth_host, '' , 'No host, no auth host');
is( $auth->get_auth_path( 'path_auth'), 'path_auth','Empty auth host' );

$auth = Gup::TestSSHAuth->new( host => 'test_host' );

my $user = getpwuid $REAL_USER_ID;

is( $auth->auth_host, "$user\@test_host" , 'Get local user');
is(
    $auth->get_auth_path('path_auth'),
    "$user\@test_host:path_auth",
    'Build correct path with default user'
);

$auth = Gup::TestSSHAuth->new( username => 'test_user' );

is( $auth->auth_host, '' , 'No host, no auth host');
is( $auth->get_auth_path( 'path_auth'), 'path_auth','Empty auth host' );

$auth = Gup::TestSSHAuth->new(
    host     => 'test_host',
    username => 'test_user',
);

is( $auth->auth_host, "test_user\@test_host" , 'Build correct auth host');
is(
    $auth->get_auth_path('path_auth'),
    "test_user\@test_host:path_auth",
    'Build correct path with test_user'
);
