package Signable::API::Party;

use strict;
use warnings;
use 5.14.0;

use parent 'Signable::API::Item';

use Carp;

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    my @required = qw(name email id);
    foreach (@required)
    {
        croak "Missing $_ in new $class" unless exists $self->{$_};
    }
    return $self;
}

sub TO_JSON
{
    my $self = shift;
    my %hash;
    $hash{"party_$_"} = $self->$_ foreach (keys %$self);
    return \%hash;
}

1;
