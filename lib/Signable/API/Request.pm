package Signable::API::Request;

use strict;
use warnings;
use 5.14.0;

use LWP;
use JSON::XS qw();
#use Tie::Hash::Indexed;
use Carp;
use Data::Dumper;

use Signable::API::Template;
use Signable::API::Document;
use Signable::API::Client;

#use constant URI => 'https://www.signable.co.uk/rest';
use constant URI => 'https://api0.signable.co.uk/rest';

# passed apiKey, apiID, format (optional)
sub new
{
    my $class = shift;
    my %params = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;
    %params = ( # Collect defaults
	format	=> 'json',
	%params
    );
    croak "No apiID passed." unless $params{apiID};
    croak "API Key should be 32 characters." unless length $params{apiKey} == 32;
    croak "Format should be json or xml." unless $params{format} =~ /^(json|xml)$/;
    $params{ua} = new LWP::UserAgent;
    my $self = \%params;
    bless $self, $class;
}

sub templates
{
    my $self = shift;
    my $start = shift // 0;
    my $limit = shift // 100;
    my $result;
    for (1 .. 3)
    {
	$result = $self->post('templates',
	    range_start => $start,
	    range_limit => $limit,
	);
	last if ref $result eq 'ARRAY';
    }
    croak Dumper $result unless ref $result eq 'ARRAY';
    local $_;
    my @templates;
    foreach (@$result)
    {
	push @templates, new Signable::API::Template($self, $_);
    }
    return wantarray ? @templates : \@templates;
}

sub template
{
    my $self = shift;
    my $id = shift;
    my @templates = $self->templates;
    my ($template) = grep { $_->id == $id } @templates;
    return $template;
}

sub newest_template
{
    my $self = shift;
    my @templates = $self->templates;
    my ($template) = sort { $b->id <=> $a->id } @templates;
    # get the highest one only
    return $template;
}

sub document
{
    my $self = shift;
    my $doc_id = shift;
    my $doc = $self->post('document',
	document_id	=> $doc_id,
    );
    return new Signable::API::Document($self, $doc);
}

sub clients
{
    my $self = shift;
    my $result = $self->post('clients');
    my @clients;
    foreach (@$result)
    {
	push @clients, new Signable::API::Client($self, $_);
    }
    return wantarray ? @clients : \@clients;
}

sub client
{
    my $self = shift;
    my $id = shift;
    my $client = $self->post('client',
	client_id   => $id,
    );
    return new Signable::API::Client($self, $client);
}

sub add_client
{
    my $self = shift;
    my $name = shift;
    my $email = shift;
    my $result = $self->post('client/add',
	client_name => $name,
	client_email => $email,
    );
    croak($result->{status_message}) unless $result->{status} eq 'success';
    return new Signable::API::Client($self, {
	    client_id	=> $result->{client_id},
	    client_name	=> $name,
	    client_email => $email,
	}
    );
}

sub activity
{
    my $self = shift;
    my $limit = shift // 100;
    my $result = $self->post('activity',
	limit	=> $limit,
    );
    return wantarray ? @$result : $result;
}

sub url
{
    my $self = shift;
    my $function = shift;
    my $url = sprintf "%s/%s/%s", URI, $self->{format}, $function;
    return $url;
}

our $DEBUG = 0;

sub post
{
    my $self = shift;
    my $func = shift;
    my %form = @_;
    my $url = $self->url($func);
    $form{api_id} = $self->{apiID};
    $form{api_key} = $self->{apiKey};
    my $response = $self->{ua}->post($url, \%form);
    if ($DEBUG)
    {
	print Dumper $response;
	exit;
    }
    my $json = new JSON::XS;
    croak $response->status_line if $response->is_error;
    $json->decode($response->decoded_content);
}

1;
