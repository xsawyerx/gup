use strict;
use warnings;
package Gup::Role::BeforeSync;
# ABSTRACT: Before sync role

use English '-no_match_vars';
use Moo::Role;
use Sub::Quote;

with 'Gup::Role::Plugin';

requires 'before_sync';

1;

__END__

