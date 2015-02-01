package Signable::API::Envelope;

use strict;
use warnings;
use 5.14.0;
use utf8;

use parent 'Signable::API::Item';

use JSON;
use Attribute::Boolean;
use Carp;

use Data::Dumper;

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
    my %params = ref $_[0] eq 'HASH' ? %{$_[0]}  : @_;
    $params{documents} = [ $params{document} ] if $params{document};
    $params{parties} = [ $params{party} ] if $params{party};
    delete $params{document};
    delete $params{party};
    my $self = $class->SUPER::new(%params);
    croak "Missing title" unless exists $self->{title};
#    croak "Missing documents" unless ref $self->{documents} eq 'ARRAY';
#    croak "Missing parties" unless ref $self->{parties} eq 'ARRAY';
    return $self;
}

sub fetch
{
    my $class = shift;
    my $fingerprint = shift // croak "No fingerprint";
    my $response = $class->get('envelopes', $fingerprint);
    return $class->new($response);
}

sub list
{
    my $class = shift;
    my @envelopes;
    my $url = 'envelopes';
    do {
        my $result = $class->get($url);
        push @envelopes, @{$result->{envelopes}};
        $url = $result->{next};
    } while ($url);
    @envelopes = map { $class->new($_); } @envelopes;
    return wantarray ? @envelopes : \@envelopes;
}

###################################################################
##
##  Instance methods
##

sub send
{
    my $self = shift;
    my %content;
    my $json = new JSON;
    $json->utf8->convert_blessed; # ->pretty;
    $content{envelope_title}  = $self->title;
    $content{user_id} = $self->{user}->id if $self->user;
    $content{envelope_password_protect} = 1 if $self->password_protect;
    $content{envelope_redirect_url} = $self->redirect_url;
    $content{envelope_documents} = $json->encode($self->documents);
    $content{envelope_parties} = $json->encode($self->parties);
    my $response = $self->post('envelopes', \%content);
}

sub reminder
{
    my $self = shift;
    my $response = $self->put('envelopes', $self->fingerprint, 'remind');
}

sub cancel
{
    my $self = shift;
    my $response = $self->put('envelopes', $self->fingerprint, 'cancel');
}

sub expire
{
    my $self = shift;
    my $response = $self->put('envelopes', $self->fingerprint, 'expire');
}







1;

