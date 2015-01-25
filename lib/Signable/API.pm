package Signable::API;

use strict;
use warnings;
use 5.14.0;
use utf8;

use Carp;

use Signable::API::Template;
use Signable::API::Envelope;
use Signable::API::Document;
use Signable::API::Party;
use Signable::API::Contact;


use constant URI => 'https://api.signable.co.uk/v1/';

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
    my $apikey = shift // croak "No API key passed";
    my $self = {};
    bless $self, $class;
    $self->APIKey($apikey);
    return $self;
}

###################################################################
##
##  Instance methods
##

sub APIKey
{
    my $self = shift;
    my $value = shift;
    $Signable::API::Item::APIKey = $value if $value;
    return $Signable::API::Item::APIKey;
}

sub template
{
    my $self = shift;
    return new Signable::API::Template(@_);
}

sub envelope
{
    my $self = shift;
    return new Signable::API::Envelope(@_);
}

sub document
{
    my $self = shift;
    return new Signable::API::Document(@_);
}

sub party
{
    my $self = shift;
    return new Signable::API::Party(@_);
}

sub contact
{
    my $self = shift;
    return new Signable::API::Contact(@_);
}


1;

