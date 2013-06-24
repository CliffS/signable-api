package Signable::Client;

use strict;
use warnings;
use 5.14.0;

sub new
{
    my $class = shift;
    my $request = shift;
    my $client = shift;
    my $self = {
	request => $request,
	client => $client,
    };
    bless $self, $class;
}

sub AUTOLOAD
{
    my $self = shift;
    (my $name = our $AUTOLOAD) =~ s/.*:://;
    return $self->{client}{"client_$name"};
}

sub DESTROY { };    # Avoid AUTOLOAD

sub update
{
    my $self = shift;
    my $name = shift;
    my $email = shift;
    my $result = $self->submit('client/update',
	WORKING HERE


1;
