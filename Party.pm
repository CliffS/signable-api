package Signable::Party;

use strict;
use warnings;
use 5.14.0;

use Data::Dumper;

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

sub merge_fields
{
    my $self = shift;
    my $merge_fields = $self->{party}{merge_fields};
    return wantarray ? @$merge_fields : $merge_fields;
}

sub client_id
{
    my $self = shift;
    return $self->{party}{client_id};
}

sub client
{
    my $self = shift;
    my $name = shift;
    $self->{data}{client} = $name if $name;
    return $self->{data}{client}
}

sub email
{
    my $self = shift;
    my $email = shift;
    $self->{data}{email} = $email if $email;
    return $self->{data}{email}
}

sub fingerprint
{
    my $self = shift;
    return $self->{party}{signature_fingerprint};
}

sub fields
{
    my $self = shift;
    if (@_ > 0)
    {
	my %fields = @_;
	my @merge_fields = $self->merge_fields;
	my %data;
	foreach my $merge_field (@merge_fields)
	{
	    my $field = $merge_field->{merge_field};
	    $data{$merge_field->{merge_field_id}} = $fields{$field};
	}
	$self->{data}{fields} = \%data;
    }
    return wantarray ? %{$self->{data}{fields}} : $self->{data}{fields};
}

sub DESTROY { };    # Avoid AUTOLOAD

1;
