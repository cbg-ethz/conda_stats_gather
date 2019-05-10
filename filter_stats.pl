#!/usr/bin/env perl

use Time::Piece;
#use Date::Parse; # perl-TimeDate
#use DateTime

use strict;
use Encode;

# package that interests us
my @packages = qw{
ngshmmalign
shorah
haploclique
indelfixer
consensusfixer
smallgenomeutilities
};

open(my $CSV, '<', 'downloads.csv');

### header
my @header = split ',', <$CSV>;
chomp $header[$#header];
# reverse map package name to column number in header
my %header = map { $header[$_] => $_ } 0 .. $#header;
# map listed packages to column numbers
my %packages = map { $_ => exists $header{$_} ? $header{$_} :  die "unknown header '$_'" } @packages;

# space for output
print "hour\t";
printf "%s%-15s\e[0m", ($header{$_} & 1) ? "\e[41m\e[48;5;237m" : '', substr $_, 0, 15
	foreach(@packages);
print "\n" x 24; #"\e[23S";

my @hourlytot = map { [ map { {} } 1 .. 12 ] } 0..1;
my %last = undef;
my %line = undef;
my $dst = 0;
while(<$CSV>) {
	# current line -> last
	%last = %line
		if exists($line{'timestamp'});

	# process line
	chomp;
	{
		my @line = split ',';
		%line = ( 'timestamp' => $line[0],
					map { $_ => $line[%packages{$_}] } @packages
				);
	}

	## TEST monotony error injection test
	##$line{'haploclique'} = 0
	##	if ($line{'timestamp'} gt '2018-11-29 22:00');

	# compute delta between last and current line
	next
		unless exists($last{'timestamp'});

	#check monotonous progression
	if (my @broken = grep { $last{$_} > $line{$_} } @packages) {
		die "monotony broken for @broken on ${line{'timestamp'}}"
	}

	# compute difference
	my %delta = map { $_ => $line{$_} - $last{$_} } @packages;
	# cumulate hourly totals
	my $tp = Time::Piece->strptime($line{'timestamp'}, '%F %R');
	# total and display
	$hourlytot[$dst][$tp->hour]->{$_} += $delta{$_}
		foreach(@packages);

	print "\r\e[" .  (23 - $tp->hour) . "A" . $tp->hour . "\t";
	printf "%s%s%5u%s%5u\e[0m",
			($header{$_} & 1) ? "\e[41m\e[48;5;237m" : '',
			$dst ? "\e[5C\e[33;1m" : "\e[36;1m",
			$hourlytot[$dst][$tp->hour]->{$_},
			$dst ? "\e[37;1m" : "\e[37;1m\e[5C",
			$hourlytot[0][$tp->hour]->{$_} + $hourlytot[1][$tp->hour]->{$_}
		foreach(@packages);
	print "\r\e[" .  (23 - $tp->hour) . "B";

#	last
	$dst = 1
		if ($line{'timestamp'} gt '2019-03-31 02:00')
}
close $CSV;

