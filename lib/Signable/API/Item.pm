package Signable::API::Item;

use strict;
use warnings;
use 5.14.0;
use utf8;

use LWP::UserAgent;
use HTTP::Request;
use HTTP::Request::Common qw( POST );
use URI;
use JSON;

use Carp;
use Data::Dumper;

use constant BASEURI => 'https://api.signable.co.uk/v1';

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
    my $self = {};
    bless $self, $class;
    my %params = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;
    foreach (keys %params)
    {
        $self->$_($params{$_});
    }
    return $self;

}

###################################################################
##
##  Instance methods
##

sub AUTOLOAD
{
    my $self = shift;
    my $value = shift;
    (my $class = ref $self) =~ s/.*::(.*)/\l$1_/;
    croak "Class routine" unless $class;
    (my $name = our $AUTOLOAD) =~ s/.*:://;
    $name =~ s/^$class//;
    $self->{$name} = $value if defined $value;
    return $self->{$name};
}

sub DESTROY { }

sub debug
{
    my $self = shift;
    my $item = shift;
    print Dumper $item;
    exit;
}

sub get
{
    my $self = shift;
    my $path = shift;
    my $url;
    if ($path =~ m'/')
    {
        $url =  new URI($path);
    }
    else {
        $url = new URI(join '/', BASEURI, $path);
        $url->query_form(@_);
    }
    my $ua = new LWP::UserAgent;
    my $request = new HTTP::Request(GET => $url);
    $request->authorization_basic(our $APIKey, 'x');
    my $response = $ua->request($request);
    croak $response->status_line unless $response->is_success;
    my $json = new JSON;
    return $json->decode($response->content);
}

sub post
{
    my $self = shift;
    my $path = shift;
    my $url = new URI(join '/', BASEURI, $path);
    my %content = @_;
    my $ua = new LWP::UserAgent;
    my $request = POST $url, Content => \%content;
    $request->authorization_basic(our $APIKey, 'x');
    my $response = $ua->request($request);
    croak $response->status_line unless $response->is_success;
    my $json = new JSON;
    return $json->decode($response->content);
}

sub delete
{
    my $self = shift;
    my $url = new URI(join '/', BASEURI, @_);
    my $ua = new LWP::UserAgent;
    my $request = new HTTP::Request(DELETE => $url);
    $request->authorization_basic(our $APIKey, 'x');
    my $response = $ua->request($request);
    croak $response->status_line unless $response->is_success;
    my $json = new JSON;
    return $json->decode($response->content);
}


1;

