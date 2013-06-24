package Signable::Document;

use strict;
use warnings;
use 5.14.0;

use Signable::Party;

sub new
{
    my $class = shift;
    my $request = shift;
    my $document = shift;
    my $self = {
	request => $request,
	document => $document,
    };
    bless $self, $class;
}

sub AUTOLOAD
{
    my $self = shift;
    (my $name = our $AUTOLOAD) =~ s/.*:://;
    return $self->{document}{"document_$name"};
}

sub DESTROY { };    # Avoid AUTOLOAD

sub parties
{
    my $self = shift;
    my $result = $self->submit('parties',
	template_id	=> $self->id,
    );
    my @parties;
    local $_;
    foreach (@$result)
    {
	push @parties, new Signable::Party($self->{request}, $_);
    }
    return wantarray ? @parties : \@parties;
}

sub submit
{
    my $self = shift;
    my $func = shift;
    $func = "document/$func";
    $self->{request}->post($func, @_);
}

1;
