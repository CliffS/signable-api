#!/usr/bin/perl

use strict;
use warnings;
use 5.14.0;
use utf8;

use lib '../..';

use Signable::API;


use Data::Dumper;

# Signable::API->APIKey('4405197452bd64a5dc1c80873c81c84c');
# Signable::API->APIKey('2b9770a0515f7bf5416f6ec224228b6a');

my $sign = new Signable::API('4405197452bd64a5dc1c80873c81c84c');

my $template = Signable::API::Template->latest;

my $env = new $sign->envelope(
    title   => 'A test envelope',
    password_protect => 1,
    redirect_url => 'http://may.be',
    document => new $sign->document(
        title => 'Letter of Engagement',
        template => $template,
    ),
    party   => new $sign->party(
        name    => 'Cliff Stanford',
        email   => 'cliff@may.be',
        id      => $template->party,
        message => 'Hello there',
    ),
);

print Dumper $env->send;
