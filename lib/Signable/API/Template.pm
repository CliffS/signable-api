package Signable::API::Template;

use strict;
use warnings;
use 5.14.0;

use parent 'Signable::API::Item';

use Carp;

###################################################################
##
##  Class methods
##

sub list
{
    my $class = shift;
    my @templates;
    my $url = 'templates';
    do {
        my $result = $class->get($url);
        push @templates, @{$result->{templates}};
        $url = $result->{next};
    } while ($url);
    @templates = map { new $class($_); } @templates;
}

sub latest
{
    my $class = shift;
    my $result = $class->get('templates', offset => -1, limit => 1);
    my @templates = @{$result->{templates}};
    return new $class($templates[0]);
}

###################################################################
##
##  Instance methods
##

sub delete
{
    my $self = shift;
    my $result = $self->SUPER::delete('templates', $self->fingerprint);
    return $result->{message};
}

1;
