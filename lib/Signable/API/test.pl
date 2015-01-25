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

my $sign = new Signable::API(LIVE);

my $template = Signable::API::Template->latest;

my $env = $sign->envelope(
    title   => 'A test envelope',
    password_protect => 1,
    redirect_url => 'http://may.be',
    document => $sign->document(
        title => 'Letter of Engagement',
        template => $template,
    ),
    party   => $sign->party(
        name    => 'Cliff Stanford',
        email   => 'cliff@may.be',
        id      => $template->party,
        message => 'Hello there',
    ),
);

print Dumper $env->send;
