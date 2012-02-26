#!/usr/bin/perl
use strict;
use warnings;
use lib 'lib';
use Test::More;
use Test::Exception;

# Check for File::Temp
eval('use File::Temp');
$@ and plan skip_all => "File::Temp required for this test";

# Test
plan tests => 8;

my $repo_name = 'test';
my $temp_dir  = File::Temp->newdir;
my $repos_dir = $temp_dir->dirname;
my $repo_dir  = $repos_dir.$repo_name;

use_ok q/Gup/;

# Positive tests
my $gup = Gup->new(
    name      => $repo_name,
    repos_dir => $repos_dir,
);

isa_ok $gup, 'Gup';
can_ok $gup, qw/create_repo update_repo/;
isa_ok $gup->create_repo, 'Git::Repository';

TODO: {
    ok 1, 'Create new file in remote host';
    ok $gup->update_repo, 'Update repo';
}

# Negative tests
$gup = Gup->new(
    name      => $repo_name,
    repos_dir => $repos_dir,
);

# $repo_dir exists from positibe testings
dies_ok sub{ $gup->create_repo }, "Dies ok, dir $repo_dir exists";

rmdir $repo_dir;
chmod '0600', $repos_dir;

dies_ok sub{ $gup->create_repo }, "Dies ok, can't write to $repo_dir";

# Should be runned, because making 
# chdir to the temp directroy
chdir '/tmp';
File::Temp->cleanup();
