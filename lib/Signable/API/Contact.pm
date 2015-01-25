package Signable::API::Contact;

use strict;
use warnings;
use 5.14.0;
use utf8;

###################################################################
##
##  Local helper functions
##


###################################################################
##
##  Class methods
##

sub fetch
{
    my $class = shift;
    my $id = shift;
    my $response = $class->get('contacts', $id);
    return new $class($response);
}

sub list
{
    my $class = shift;
    my @contacts;
    my $url = 'contacts';
    do {
        my $result = $class->get($url);
        push @contacts, @{$result->{contacts}};
        $url = $result->{next};
    } while ($url);
    @contacts = map { new $class($_) } @contacts;
    return wantarray ? @contacts : \@contacts;
}

###################################################################
##
##  Instance methods
##

sub save
{
    my $self = shift;
    croak "Missing name / email" unless $self->{name} && $self->{email};
    my %params;
    $params{contact_name} = $self->name;
    $params{contact_email} = $self->email;
    if ($self->id)  # Update
    {
        $self->put('contacts', $self->id, {
                contact_name => $self->name,
                contact_email => $self->email,
            }
        );
    }
    else {          # Create
        my $response = $self->post('contacts', {
                contact_name => $self->name,
                contact_email => $self->email,
            }
        );
        $self->id($response->{contact_id});
    }
    return $self->id;
}

sub delete
{
    my $self = shift;
    return $self->delete('contacts', $self->id);
}

sub envelopes
{
    # to be written
}

1;

