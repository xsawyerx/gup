#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 7;
use t::lib::Functions;

our $gup = t::lib::Functions::create_test_gup;

use_ok( 'Gup::Plugin::Sync::Mysql' );

# Create System::Command mock
no warnings qw( redefine once );

*System::Command::new = sub {
    my $class = shift;
    my $cmd   = shift;

    if( $cmd eq '/usr/bin/ssh' ) {
        my $host   = shift;
        my $md_cmd = shift;

        is( $host, '', 'Host at user should be empty' );
        is(
            $md_cmd,
            '/usr/bin/mysqldump -u test_user -ptest_password'.
            ' --databases test_password test_args > /tmp/dump.sql',
            'Check mysqldump command',
        );
    }

    if( $cmd eq '/usr/bin/scp' ) {
        my $file = shift;
        my $dir  = shift;

        is( $file, '/tmp/dump.sql', 'Remote file correct' );
        is( $dir,  $gup->repo_dir, 'Is local test dir correct' );
    }

    $class;
};
*System::Command::_reap = sub { };
*System::Command::exit  = sub { 0 };
*System::Command::close = sub { 1 };

my $mysql = Gup::Plugin::Sync::Mysql->new(
    source_dir          => '/tmp',
    gup                 => $gup,
    mysqldump_user      => 'test_user',
    mysqldump_password  => 'test_password',
    mysqldump_databases => 'test_password',
    mysqldump_args      => 'test_args',
);

ok( $mysql->before_sync, 'Successful before_sync' );
ok( $mysql->sync,        'Successful sync' );
