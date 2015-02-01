#!/usr/bin/perl

use strict;
use warnings;
use 5.14.0;
use utf8;

use lib '../..';

use Signable::API;

use constant {
    TEST    => '4405197452bd64a5dc1c80873c81c84c',
    LIVE    => '2b9770a0515f7bf5416f6ec224228b6a',
};

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my $sign = new Signable::API(LIVE);

my @envelopes = Signable::API::Envelope->list;

foreach (@envelopes)
{
    state $count = 0;
    say "[$count] ", $_->status;
    $count++;
    next if $_->status =~ /signed|expired|rejected|cancelled/;
    my $result = eval { $_->expire };
    if ($@)
    {
        chomp (my $err = $@);
        say $err;
    }
    else {
        chomp $result->{message};
        chomp $result->{envelope_fingerprint};
        say $result->{message}, ' ' , $result->{envelope_fingerprint};
    }
}

#print Dumper \@envelopes;
