use strict;
use warnings;
package Gup::Role::AfterSync;
# ABSTRACT: After sync role

use English '-no_match_vars';
use Moo::Role;
use Sub::Quote;

with 'Gup::Role::Plugin';

requires 'after_sync';

1;

__END__

