#!/usr/bin/perl

use strict;
use warnings;
use 5.14.0;
use utf8;

use lib '../..';

use Signable::API::Item;
use Signable::API::Template;

use Data::Dumper;

$Signable::API::Item::APIKey = '4405197452bd64a5dc1c80873c81c84c';

my @templates = Signable::API::Template->list;

# print Dumper \@templates;

my $first = Signable::API::Template->latest;

# print Dumper $first;

print Dumper $first->delete;
