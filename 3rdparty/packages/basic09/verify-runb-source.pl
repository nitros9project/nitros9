#!/usr/bin/env perl
use strict;
use warnings;

my ($basic09, $runb) = @ARGV;
die "usage: $0 basic09.asm runb.asm\n" unless defined $basic09 && defined $runb;

my $basic09_core = runb_core($basic09);
my $runb_core = runb_core($runb);

exit 0 if $basic09_core eq $runb_core;

my @basic09_lines = split /\n/, $basic09_core, -1;
my @runb_lines = split /\n/, $runb_core, -1;
my $limit = @basic09_lines > @runb_lines ? @basic09_lines : @runb_lines;
for my $i (0 .. $limit - 1) {
    my $left = $basic09_lines[$i] // '<missing>';
    my $right = $runb_lines[$i] // '<missing>';
    next if $left eq $right;
    my $line = $i + 1;
    die "RunB source mismatch at core line $line\nbasic09.asm: $left\nrunb.asm:    $right\n";
}

die "RunB source mismatch\n";

sub runb_core {
    my ($file) = @_;
    open my $fh, '<', $file or die "open $file: $!\n";
    local $/;
    my $source = <$fh>;
    close $fh;

    return $1 if $source =~ /^(L0000\s+mod\s+eom,name,tylg,atrv,start,dsize\n.*?^eom\s+equ\s+\*)/ms;
    die "could not find RunB core in $file\n";
}
