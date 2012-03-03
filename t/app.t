#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 2;

use Gup::App;

my $gup_app = Gup::App->new( name => 'test' );

isa_ok( $gup_app, 'Gup::App' );
can_ok( $gup_app, qw/run command_new command_update/ ); 
