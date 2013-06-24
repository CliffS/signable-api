package Signable::Template;

use strict;
use warnings;
use 5.14.0;

use Data::Dumper;

use Signable::Document;

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

sub parties
{
    my $self = shift;
    my $result = $self->submit('parties',
	template_id => $self->id,
    );
    local $_;
    my @parties;
    foreach (@$result)
    {
	push @parties, new Signable::Party($self->{request}, $_);
    }
    return wantarray ? @parties : \@parties;
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

sub submit
{
    my $self = shift;
    my $func = shift;
    $func = "template/$func";
    $self->{request}->post($func, @_);
}

1;
