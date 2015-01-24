package Signable::API;

use strict;
use warnings;
use 5.14.0;
use utf8;

use constant URL => 'https://api.signable.co.uk/v1/';

###################################################################
##
##  Local helper functions
##


###################################################################
##
##  Class methods
##

sub new
{
    my $class = shift;
    my $self = {};
    $self->{apikey} = shift // croak "No API key passed";
    $self->{ua} = new LWP::UserAgent;
    bless $self, $class;
}

###################################################################
##
##  Instance methods
##

sub AUTOLOAD
{
    my $self = shift;
    my $value = shift;
    (my $name = our $AUTOLOAD) =~ s/.*:://;
    $self->{$name} = $value if defined $value;
    return $self->{$name};
}

sub DESTROY { }

1;

