package Signable::API::Client;

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
	client_id   => $self->id,
	client_name => $name,
	client_email => $email,
    );
    croak($result->{status_message}) unless $result->{status} eq 'success';
    $self->{client}{client_name} = $name;    
    $self->{client}{client_email} = $email;    
}

sub documents
{
    my $self = shift;
    my @documents;
    if ($self->{documents})
    {
	@documents = @{$self->{documents}};
    }
    else {
	my $result = $self->submit('documents',
	    client_id   => $self->id,
	);
	foreach my $doc (@$result)
	{
	    push @documents, new Signable::API::Document(
		$self->{request},
		$doc
	    );
	}
    }
    return wantarray ? @documents : \@documents;
}

sub document
{
    my $self = shift;
    my $id = shift;
    my @docs = $self->documents;
    @docs = grep { $_->id == $id } @docs;
    return $docs[0];
}

sub add_mergefield
{
    my $self = shift;
    my $name = shift;
    my $value = shift;
    my $result = $self->submit('mergefield/add',
	client_id   => $self->id,
	merge_field => $name,
	merge_field_value => $value,
    );
    croak($result->{status_message}) unless $result->{status} eq 'success';
}

sub update_mergefield
{
    my $self = shift;
    my $name = shift;
    my $value = shift;
    my $result = $self->submit('update/mergefield',
	client_id   => $self->id,
	merge_field => $name,
	merge_field_value => $value,
    );
    croak($result->{status_message}) unless $result->{status} eq 'success';
}

sub delete
{
    my $self = shift;
    my $result = $self->submit('remove',
	client_id   => $self->id,
    );
    croak($result->{status_message}) unless $result->{status} eq 'success';
}

sub submit
{
    my $self = shift;
    my $func = shift;
    $func = "client/$func";
    $self->{request}->post($func, @_);
}

1;
