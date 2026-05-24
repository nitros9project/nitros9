#!/usr/bin/env perl
use strict;
use warnings;

my ($basic09) = @ARGV;
die "usage: $0 basic09.asm\n"
    unless defined $basic09;

for my $shared_source (qw(basic09_rlcmp.asm basic09_floatfix.asm basic09_scalar.asm basic09_sqrt.asm basic09_miscfunc.asm basic09_logexp.asm basic09_compare.asm basic09_strops.asm basic09_trig.asm)) {
    require_include($basic09, $shared_source);
}
exit 0;

sub require_include {
    my ($file, $include_file) = @_;
    open my $fh, '<', $file or die "open $file: $!\n";
    local $/;
    my $source = <$fh>;
    close $fh;

    my $include = quotemeta $include_file;
    return if $source =~ /^\s+use\s+$include\s*$/m;
    die "$file does not include $include_file\n";
}
