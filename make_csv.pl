#!/usr/bin/env perl
 

use strict;
use Encode;

use YAML::PP;
my $ypp = YAML::PP->new;

my $path = 'out';

#  load_file returns a perl array of all section, deref to get the first yaml list (and ignore other sections)
my @packages = @{$ypp->load_file("make_csv.yaml")};

# my @packages = qw{
# ngshmmalign
# shorah
# haploclique
# indelfixer
# consensusfixer
# smallgenomeutilities
# cojac
# lollipop
# viloca
#
# lofreq
# mvicuna
# prinseq
# mafft
# bwa
# samtools
# picard
# snakemake
# savage
# };

# Parameter: Filtering Parameter
my $filter = undef;
if (defined($ARGV[0])) {
	unless ($ARGV[0] =~ m{^[[:digit:]]{4,}$}) {
		print STDERR "Wrong pattern: <${ARGV[0]}>\n";
		exit 1;
	}
	$filter = qr{^(?:${ARGV[0]})};
}
my $count = 0;


my $cur = { 't' => '', map +( $_ => 0 ), @packages };
sub flush {
	my $cur = pop;

	# timestamnp ?
	if (length $cur->{'t'}) {
		# table line
		print $cur->{'t'};
		foreach (@packages) {
			print ",$cur->{$_}";
			$cur->{$_} = 0;
		}
	} else {
		# header
		print (join ',', ('timestamp', @packages));
	}
	print "\n";
}

opendir(my $dh, $path) or die "Can't open ${path}: $!";
# TODO pack/unpack files, per year subdir, etc.
foreach (sort readdir $dh) {
	next if defined($filter) && $_ !~ $filter;
	next unless $_ =~ m{(?<y>[[:digit:]]{4})(?<m>[[:digit:]]{2})(?<d>[[:digit:]]{2})(?<h>[[:digit:]]{2})-(?<n>[^\.]+)\.json};

	my $t = "$+{y}-$+{m}-$+{d} $+{h}:00";
	if ($t ne $cur->{'t'}) {
		flush $cur;
		$cur->{'t'} = $t;
	};
	my $n = $+{n};

	my $data;
	{
		open my $fh, '<', "$path/$_" or die "Can't open ${path}: $!";
		local $/ = undef;
		$data = <$fh>;
		close $fh;
	}
	$cur->{$n} = 0;
	$cur->{$n} += $1
		while $data =~ m{["']ndownloads["']:\s+([[:digit:]]+)}g;
}
flush $cur;
closedir $dh;
