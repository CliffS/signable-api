package Signable::Template;

use strict;
use warnings;
use 5.14.0;

#use Tie::Hash::Indexed;

use Data::Dumper;
use Carp;

use Signable::Document;
use Signable::Client;

sub new
{
    my $class = shift;
    my $request = shift;
    my $template = shift;
    my $self = {
	request => $request,
	template => $template,
    };
    bless $self, $class;
}

sub AUTOLOAD
{
    my $self = shift;
    (my $name = our $AUTOLOAD) =~ s/.*:://;
    return $self->{template}{"template_$name"};
}

sub DESTROY { };    # Avoid AUTOLOAD

sub list
{
    my $self = shift;
    my $start = shift // 0;
    my $limit = shift // 100;
    my $result = $self->submit('list',
	range_start => $start,
	range_limit => $limit,
	template_fingerprint => $self->fingerprint,
    );
    local $_;
    my @documents;
    foreach (@$result)
    {
	push @documents, new Signable::Document($self->{request}, $_);
    }
    return wantarray ? @documents : \@documents;
}

sub document
{
    my $self = shift;
    my $id = shift;
    say "id = $id";
    my @docs = $self->list;
    @docs = grep { $_->id == $id } @docs;
    croak "Should only be one match" unless @docs == 1;
    return shift @docs;
}

sub parties
{
    my $self = shift;
    local $_;
    my @parties;
    if ($self->{parties})   # only make the call once
    {
	@parties = @{$self->{parties}};
    }
    else {
	my $result = $self->submit('parties',
	    template_id => $self->id,
	);
	foreach (@$result)
	{
	    push @parties, new Signable::Party($self->{request}, $_);
	}
	$self->{parties} = \@parties;
    }
    return wantarray ? @parties : \@parties;
}

sub party
{
    my $self = shift;
    my $name = shift;
    my @parties = $self->parties;
    my ($party) = grep { $_->name eq $name } @parties;
    return $party;
}

sub rename
{
    my $self = shift;
    my $new_name = shift;
    my $result = $self->submit('update/title',
	template_id		=> $self->id,
	template_fingerprint	=> $self->fingerprint,
	template_title		=> $new_name,
    );
    croak($result->{status_message}) unless $result->{status} eq 'success';
    $self->{template}{template_title} = $new_name;
    $self->{template}{template_id} = $result->{template_id};
}

sub remove
{
    my $self = shift;
    my $result = $self->submit('remove',
	template_id		=> $self->id,
    );
    croak $result->{status_message} unless $result->{status} eq 'success';
}

sub send    # Returns the document
{
    my $self = shift;
    my $protect = shift;
    my @parties = $self->parties;
    my %params;
    $params{template_id} = $self->id;
    $params{password_protect} = $protect ? 1 : 0;
    foreach my $party (0 .. $#parties)
    {
	$params{"party_id[$party]"} = $parties[$party]->id;
	$params{"party_name[$party]"} = $parties[$party]->client;
	$params{"party_email[$party]"} = $parties[$party]->email;
	my %fields = $parties[$party]->fields;
	$params{"merge_field[$_]"} = $fields{$_} foreach (keys %fields);
    }
    my @params = %params;
    my $response = $self->doc_submit('send', @params);
    croak $response->{status_message} unless $response->{status} eq 'success';
    print Dumper $response; # exit;
    my $id = $response->{document}{document_id};
    my $doc = $self->{request}->document($id);
    return $doc;
}

sub clients
{
    my $self = shift;
    my @clients = $self->{clients};
    return wantarray ? @clients : \@clients;
}

sub submit
{
    my $self = shift;
    my $func = shift;
    $func = "template/$func";
    $self->{request}->post($func, @_);
}

sub doc_submit
{
    my $self = shift;
    my $func = shift;
    $func = "document/$func";
    $self->{request}->post($func, @_);
}

1;
