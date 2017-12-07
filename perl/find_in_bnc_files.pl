#!/usr/bin/perl

use strict;

my ($base_path, $outputfile, $searchtype, $searchstring) = @ARGV;

opendir(BNC, $base_path) or die $!;

open(OUT, ">$outputfile");
my $totfound = 0;
while (my $txt = readdir(BNC))
{
	if ($txt =~ /\.txt$/i)
	{
		open(INN, "$base_path$txt");
		my @content = <INN>;
		close(INN);
		print "Searching $txt\n";
		foreach my $line (@content)
		{
		    chomp($line);
			my ($id, $orig, $raw, $lemma, $pos, $mixed) = split/\t/, $line;
			if ($searchtype eq "raw")
			{
				if ($raw =~ /$searchstring/)
				{
				    $totfound++;
					print OUT "$orig\t$raw\t$mixed\n";
				}
			}
			if ($searchtype eq "mixed")
			{
				if ($mixed =~ /$searchstring/)
				{
				    $totfound++;
					#print "$searchstring : $mixed\n";
					# print OUT "$orig\t$raw\t$mixed\n";
					print OUT "$id\t$raw\t$mixed\n\n";
				}
			}
		}
	}
}
print "Total found: $totfound\n";
close(OUT);
exit;
