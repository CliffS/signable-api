package Signable::Document;

use strict;
use warnings;
use 5.14.0;

use Signable::Party;

use Data::Dumper;

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
    $self->parties;
    return $self;
}

sub AUTOLOAD
{
    my $self = shift;
    (my $name = our $AUTOLOAD) =~ s/.*:://;
    return $self->{document}{"document_$name"};
}

sub DESTROY { };    # Avoid AUTOLOAD

sub fingerprint
{
    my $self = shift;
    return $self->{document}{template_fingerprint};
}

use constant SIGNURL => 'https://app.signable.co.uk/contract/sign';
#CLIENT_ID/COMPANY_ID/CONTRACT_ID/CONTRACT_FINGERPRINT/SIGNATURE_FINGERPRINT

sub sign_urls
{
    my $self = shift;
    my @parties = $self->parties;
    my $template_fingerprint = $self->fingerprint;
    my $company_id = $self->{request}{apiID};
    my @urls;
    foreach my $party (@parties)
    {
	my @params = (
	    SIGNURL,
	    $party->client_id,
	    $self->{request}{apiID},
	    $self->id,
	    $self->fingerprint,
	    $party->fingerprint,
	);
	my $url = sprintf('%s/%d/%d/%d/%f/%f', @params);
	push @urls, $url;
    }
    return wantarray ? @urls : @urls > 1 ? \@urls : $urls[0];
}

sub parties
{
    my $self = shift;
    my $parties;
    if ($self->{parties})
    {
	$parties = $self->{parties};
    }
    elsif ($self->{document}{party})
    {
	my @parties;
	foreach my $party (@{$self->{document}{party}})
	{
	    push @parties, new Signable::Party($self->{template}, $party);
	}
	$parties = \@parties;
    }
    else {
	my $result = $self->submit('parties',
	    template_id	=> $self->id,
	);
	my @parties;
	foreach my $party (@$result)
	{
	    push @parties, new Signable::Party($self->{request}, $party);
	}
	$parties = \@parties;
    }
    $self->{parties} = $parties;
    return wantarray ? @$parties : $parties;
}

sub submit
{
    my $self = shift;
    my $func = shift;
    $func = "document/$func";
    $self->{request}->post($func, @_);
}

1;
