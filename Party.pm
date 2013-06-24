package Signable::Party;

use strict;
use warnings;
use 5.14.0;

sub new
{
    my $class = shift;
    my $request = shift;
    my $party = shift;
    my $self = {
	request => $request,
	party => $party,
    };
    bless $self, $class;
}

sub AUTOLOAD
{
    my $self = shift;
    (my $name = our $AUTOLOAD) =~ s/.*:://;
    return $self->{party}{"party_$name"};
}

sub DESTROY { };    # Avoid AUTOLOAD

1;
