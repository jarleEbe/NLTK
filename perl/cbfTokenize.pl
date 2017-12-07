#!/usr/bin/perl

use strict;
use utf8;

my ($basePath) = @ARGV;
my $resultPath = $basePath;
#$resultPath =~ s/test/result/;

opendir(DS, $basePath) or die $!;
my $numFiles = 0;
while (my $txt = readdir(DS))
{
	if ($txt =~ /\.txt$/i)
	{
		$numFiles++;
		open(INN, "$basePath$txt");
		binmode INN, ":utf8";
		my @content = <INN>;
		close(INN);
		my $outputfile = $txt;
		$outputfile =~ s/\.txt/_tokenized\.txt/;
		open(OUT, ">$resultPath$outputfile");
		binmode OUT, ":utf8";
		print "Tokenizing $txt\n";
		my $lineindex = 0;
		foreach my $line (@content)
		{
		    chomp($line);
			$line =~ s/^\x{FEFF}//;
			$line =~ s/\x{000B}//g;

			$line =~ s/<([^>]+?)>//g;

			$line =~ s/_/ /g;
			$line =~ s/\*//g;
			$line =~ s/\|//g;

			$line =~ s/--/—/g;
			$line =~ s/−/—/g;

			$line =~ s/&mdash;/—/g;
			$line =~ s/&dash;/—/g;
			$line =~ s/—/ — /g;

			$line =~ s/“/"/g;
			$line =~ s/”/"/g;

			$line =~ s/‘/'/g;
			$line =~ s/’/'/g;
			$line =~ s/´/'/g;
			$line =~ s/`/'/g;
			$line =~ s/ʻ/'/g;
			$line =~ s/ʼ/'/g;

			$line =~ s/…/\.\.\./g;
			$line =~ s/�/ /g;

			$line =~ s/ \s+/ /g;

			$lineindex++;
			my $alphanum = '';
			my @tokenArr = ();
			my $char = '';
			my $preceding = '';
			my $following = '';
			my $follow2 = '';
			my $follow3 = '';
			my $follow4 = '';
			my @unit = split//, $line;
			for (my $ind = 0; $ind <= $#unit; $ind++)
			{
				$char = $unit[$ind];
				if ($ind <= $#unit)
				{
					$following = $unit[$ind + 1];
				}
				else
				{
					$following = '';
				}
				if (($ind + 1) <= $#unit) #Contracted 's, 'd, 'm
				{
					$follow2 = $unit[$ind + 2];
				}
				else
				{
					$follow2 = '';
				}
				if (($ind + 2) <= $#unit) #Contracted 'll, 're, 've
				{
					$follow3 = $unit[$ind + 3];
				}
				else
				{
					$follow3 = '';
				}
				if (($ind + 4) <= $#unit) #Contracted 'tis
				{
					$follow4 = $unit[$ind + 4];
				}
				else
				{
					$follow4 = '';
				}
				if ($char =~ /[\t\n\f\r\p{IsZ}]/) #White space
				{
					if ($alphanum ne '')
					{
						push(@tokenArr, $alphanum);
						$alphanum = '';
					}
#					push(@tokenArr, ' ');
				}
				elsif ($char =~ /\p{isAlnum}/ || ($char eq '-' && $preceding =~ /\p{isAlnum}/) ) #Hyphenated words
				{
#					print "$alphanum : $char\n";
					$alphanum = $alphanum . $char;
				}
				elsif ($char eq "'") #Genitive and contracted forms
				{
#					print "$char : $following : $follow2 : $ind : $#unit\n";
					if ( ($following =~ /[dms]/i) && ( ($follow2 eq ' ') || (($ind + 1) == $#unit) )) #'d, 'm, 's
					{
							$alphanum = $alphanum . $char;	
					}
					elsif ( ( ($following =~ /[l]/i) && ($follow2 =~ /[l]/i) ) || ( ($following =~ /[r]/i) && ($follow2 =~ /[e]/i) ) || ( ($following =~ /[v]/i) && ($follow2 =~ /[e]/i) ) && ( ($follow3 eq ' ') || (($ind + 2) == $#unit) )) #'ll, 're, 've
					{
							$alphanum = $alphanum . $char;
					}
					elsif ( ($following =~ /[t]/i) && ($follow2 =~ /[i]/i) && ($follow3 =~ /[s]/i) && ( ($follow4 eq ' ') || (($ind + 3) == $#unit) )) #'tis
					{
							$alphanum = $alphanum . $char;
					}
					elsif ($ind >= 0 && $preceding =~ /\p{isAlnum}/ && $following =~ /\p{isAlnum}/)
					{
						$alphanum = $alphanum . $char;
					}
					else
					{
						if ($alphanum ne '')
						{
							push(@tokenArr, $alphanum);
							$alphanum = '';
						}
#						push(@tokenArr, $char);
						push(@tokenArr, '"');
					}
				}
				else
				{
#					print "$alphanum : $char\n";
					if ($alphanum ne '')
					{
						push(@tokenArr, $alphanum);
						$alphanum = '';
					}
					push(@tokenArr, $char);
				}
				$preceding = $char;
			}
			if ($alphanum ne '')
			{
				push(@tokenArr, $alphanum);
			}
			foreach my $token (@tokenArr)
			{
				print OUT "$token ";
			}
		}
		close(OUT);
	}
}
close(DS);
print "No. files processed: $numFiles\n";
exit;
