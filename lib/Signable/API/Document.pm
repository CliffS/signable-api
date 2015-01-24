package Signable::API::Document;

use strict;
use warnings;
use 5.14.0;

use parent 'Signable::API::Item';

use Carp;

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    my @required = qw(title template);
    foreach (@required)
    {
        croak "Missing $_ in new $class" unless exists $self->{$_};
    }
    return $self;
}

sub TO_JSON
{
    my $self = shift;
    my %hash;
    $hash{document_title} = $self->title;
    $hash{document_template_fingerprint} = $self->template->fingerprint;
    $hash{document_merge_fields} = $self->merge_fields if $self->merge_fields;
    return \%hash;
}

1;
