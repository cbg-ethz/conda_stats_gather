#!/usr/bin/env perl
 

use strict;
use Encode;


my $path = 'out';



my @packages = qw{ 
ngshmmalign
shorah
haploclique
indelfixer
consensusfixer
smallgenomeutilities

lofreq
mvicuna
prinseq
mafft
bwa
samtools
picard
snakemake
savage
};

my $cur = { 't' => '', map { '$_' => 0 }, @packages };
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
