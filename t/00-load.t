#!perl -T
use 5.14.0;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Signable::API' ) || print "Bail out!\n";
}

diag( "Testing Signable::API $Signable::API::VERSION, Perl $], $^X" );
