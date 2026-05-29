#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename qw(dirname);
use File::Path qw(make_path);
use Cwd qw(abs_path);

my ($mode, $outfile, @extra_defs) = @ARGV;
die "usage: $0 basic09|runb output [lwasm-defs...]\n"
    unless defined $mode && defined $outfile;
die "mode must be basic09 or runb\n" unless $mode eq 'basic09' || $mode eq 'runb';

my $here = dirname(abs_path($0));
my $root = abs_path("$here/../../..");
my $src = "$here/modular";
my $outdir = abs_path(dirname($outfile));
die "output directory does not exist for $outfile\n" unless defined $outdir;
my $build = "$outdir/.modular-build/$mode";
make_path($build);

my @modules = qw(comand compil binder stmts exprsn cnvio);
my @objs;
my @defs = (
    '-DNOS9VER=', '-DNOS9MAJ=', '-DNOS9MIN=',
    $mode eq 'runb' ? '-DINCLUDED=RUNTIM+MATHPAK' : (),
    @extra_defs,
);

for my $module (@modules) {
    my $in = "$src/$module.asm";
    my $out = "$build/$module";
    my @cmd = (
        'lwasm',
        '--no-warn=ifp1',
        '--6309',
        '--format=os9',
        '--pragma=pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal,noforwardrefmax',
        "--includedir=$src",
        "--includedir=$root/defs",
        @defs,
        "-o$out",
        $in,
    );
    system(@cmd) == 0 or die "failed assembling $module\n";
    push @objs, $out;
}

my $image = '';
my @starts;
for my $obj (@objs) {
    push @starts, length($image);
    open my $fh, '<:raw', $obj or die "open $obj: $!\n";
    local $/;
    $image .= <$fh>;
}

my $size = length($image);
die "modular output is too large: $size\n" if $size > 0xffff;

put16(\$image, 0x02, $size);
for my $i (1 .. $#starts) {
    # The first vector points inside comand; the remaining vectors are
    # absolute offsets to the merged component starts.
    put16(\$image, 0x0d + ($i * 2), $starts[$i]);
}
substr($image, 0x08, 1) = chr(header_parity($image));

my $crc = module_crc($image, $size - 3) ^ 0xffffff;
substr($image, $size - 3, 3) = pack('C3', ($crc >> 16) & 0xff, ($crc >> 8) & 0xff, $crc & 0xff);
die "internal CRC failure\n" unless module_crc($image, $size) == 0x800fe3;

open my $fh, '>:raw', $outfile or die "create $outfile: $!\n";
print {$fh} $image;
close $fh;

sub put16 {
    my ($ref, $offset, $value) = @_;
    substr($$ref, $offset, 2) = pack('n', $value);
}

sub header_parity {
    my ($image) = @_;
    my $xor = 0;
    for my $i (0 .. 7) {
        $xor ^= ord(substr($image, $i, 1));
    }
    return $xor ^ 0xff;
}

sub module_crc {
    my ($image, $len) = @_;
    my $accum = 0xffffff;
    for my $i (0 .. $len - 1) {
        $accum &= 0x00ffffff;
        my $b = ord(substr($image, $i, 1)) << 16;
        $b ^= $accum;
        $accum = ($accum << 8) & 0xffffffff;
        $b >>= 16;
        my $bits = 0;
        for my $bit (0 .. 7) {
            ++$bits if $b & (1 << $bit);
        }
        $accum ^= ($b << 1) ^ ($b << 6);
        $accum ^= 0x00800021 if $bits & 1;
    }
    return $accum & 0x00ffffff;
}
