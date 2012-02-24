#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 3;

use lib 'lib';

use_ok('Gup::App');

my $gup_app = Gup::App->new( name => 'tests' );

isa_ok( $gup_app, 'Gup::App' );
can_ok( $gup_app, qw/parse_args run command_new/ ); 
