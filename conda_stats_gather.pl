#!/usr/bin/env perl
 

use strict;
use Encode;

# use LWP::Simple; # my $content = get($url);

use File::Fetch;
use File::Copy;

use POSIX qw(strftime);

# my $json;
# if (eval (qq{require JSON;})) {
# 	$json = JSON->new->utf8->pretty;
# } elsif (eval (qq{require JSON::PP;})) {
# 	$json = JSON::PP->new->utf8->pretty;
# } else {
# 	die "No JSON available\n";
# }


my $channel = "bioconda";
#gawk '$1~/:$/{d=($1~/^depend/)}$2&&d{match($2,/^[^<=>]+/,o);print o[0]}' ../V-pipe/envs/*.yaml|sort -u
#grep -oP '(?<=//bioconda.github.io/recipes/)[^/]+(?=/README.html)' 0_pipeline.md
my @packages = qw{ 
snakemake
prinseq
mvicuna
indelfixer
consensusfixer
ngshmmalign
bwa
mafft
shorah
lofreq
savage
haploclique
smallgenomeutilities
samtools
picard
};

#https://api.anaconda.org/package/bioconda/{package}

foreach ( @packages ) {
	# optimization : https://metacpan.org/pod/LWP::UserAgent with keep_alive
	my $ff = File::Fetch->new(uri => "https://api.anaconda.org/package/bioconda/${_}");  # /files for downloads only
	my $data;
	my $fname = $ff->fetch(\$data, to => 'tmp/' ) or die $ff->error;

	move($fname, strftime "out/%Y%m%d%H-${_}.json", localtime);
}
