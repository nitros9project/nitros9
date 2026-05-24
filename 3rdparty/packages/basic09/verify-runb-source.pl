#!/usr/bin/env perl
use strict;
use warnings;

my ($basic09, $runb, $core) = @ARGV;
die "usage: $0 basic09.asm runb.asm runb_core.asm\n"
    unless defined $basic09 && defined $runb && defined $core;

require_include($basic09, $core);
require_include($runb, $core);

my $core_source = runb_core($core);
require_nested_include($basic09, 'basic09_rlcmp.asm');
require_nested_include($core, 'basic09_rlcmp.asm', $core_source);
exit 0;

sub require_include {
    my ($file, $core_file) = @_;
    open my $fh, '<', $file or die "open $file: $!\n";
    local $/;
    my $source = <$fh>;
    close $fh;

    my $include = quotemeta $core_file;
    return if $source =~ /^\s+use\s+$include\s*$/m;
    die "$file does not include $core_file\n";
}

sub runb_core {
    my ($file) = @_;
    open my $fh, '<', $file or die "open $file: $!\n";
    local $/;
    my $source = <$fh>;
    close $fh;

    return $1 if $source =~ /^(L0000\s+mod\s+eom,name,tylg,atrv,start,dsize\n.*?^eom\s+equ\s+\*)/ms;
    die "could not find RunB core in $file\n";
}

sub require_nested_include {
    my ($file, $include_file, $source) = @_;
    if (!defined $source) {
        open my $fh, '<', $file or die "open $file: $!\n";
        local $/;
        $source = <$fh>;
        close $fh;
    }

    my $include = quotemeta $include_file;
    return if $source =~ /^\s+use\s+$include\s*$/m;
    die "$file does not include $include_file\n";
}
