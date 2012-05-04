use strict;
use warnings;
use Test::More tests => 5;
use Test::Fatal;
use Test::Output;
use t::lib::Functions;

use Gup;

like(
    exception {
        package Gup::NoBS;
        use Moo;
        with 'Gup::Role::BeforeSync';
    },
    qr/^Can't apply Gup::Role::BeforeSync to Gup::NoBS - missing before_sync/,
    'Gup::Role::AfterSync requires a before_sync method',
);

like(
    exception {
        package Gup::NoAS;
        use Moo;
        with 'Gup::Role::AfterSync';
    },
    qr/^Can't apply Gup::Role::AfterSync to Gup::NoAS - missing after_sync/,
    'Gup::Role::AfterSync requires a after_sync method',
);

{
    package Gup::Plugin::TestBeforeSync;
    use Moo;
    with 'Gup::Role::BeforeSync';
    sub before_sync{ print '[Before sync]'; }
}

{
    package Gup::Plugin::TestAfterSync;
    use Moo;
    with 'Gup::Role::AfterSync';
    sub after_sync{ print '[After sync]'; };
}

{
    package Gup::Plugin::Sync::TestSync;
    use Moo;
    with 'Gup::Role::Sync';
    sub sync{ print '[Sync method]'; }
}

isa_ok(
    Gup::Plugin::TestBeforeSync->new(
        gup => t::lib::Functions::create_test_gup,
    ),
    'Gup::Plugin::TestBeforeSync',
);

isa_ok(
    Gup::Plugin::TestAfterSync->new(
        gup => t::lib::Functions::create_test_gup,
    ),
    'Gup::Plugin::TestAfterSync',
);

my $gup = Gup->new(
    repo_dir     => t::lib::Functions::create_test_dir,
    plugins      => [ 'TestBeforeSync', 'Sync::TestSync', 'TestAfterSync' ],
    plugins_args => { 'Sync::TestSync' => { source_dir => undef } },
);

stdout_is(
    sub{ $gup->sync_repo },
    '[Before sync][Sync method][After sync]',
    'Check running order of sync methods',
);
