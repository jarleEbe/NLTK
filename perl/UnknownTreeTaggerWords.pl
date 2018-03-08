#!/usr/bin/perl

use strict;
use utf8;

my ($basePath, $resultPath) = @ARGV;
#my $resultPath = $basePath;
#$resultPath =~ s/test/result/;
open(UNKNOWN, ">unknown.txt");
binmode UNKNOWN, ":utf8";

opendir(DS, $basePath) or die $!;
my $numFiles = 0;
while (my $txt = readdir(DS))
{
	if ($txt =~ /_tagged\.txt$/i)
	{
		$numFiles++;
		open(INN, "$basePath$txt");
		binmode INN, ":utf8";
		my @content = <INN>;
		close(INN);
		my $outputfile = $txt;
		open(OUT, ">$resultPath$outputfile");
		binmode OUT, ":utf8";
		print "Re-lemmatising <unknown> lemmas $txt\n";
        my $totlines = $#content;
        my @newcontent = ();
#		foreach my $line (@content)
        my $previous = $content[0];
        chomp($previous);
        push(@newcontent, $previous);
        my $ampflag = 0;
		foreach (my $ind = 1; $ind <= $totlines; $ind++)
		{
            my $line = $content[$ind];
		    chomp($line);
            my @cols = split/\t/, $line;
            if ($ampflag == 1)
            {
                $ampflag = 0;
                print "Removed row (;) after &amp: $line\n";
            }
            elsif ($#cols > 1)
            {
                my $word = $cols[0];
                my $pos = $cols[1];
                my $lemma = $cols[2];
                if ($lemma eq '<unknown>' && $word =~ /-/)
                {
#                    print "Possible: $word\n";
                    if (&possibleNnumber($word) == 1)
                    {
                        my $newlemma = $word;
                        $newlemma = lc($newlemma);
                        my $temp = "$word\tCD\t$newlemma";
                        push(@newcontent, $temp);
                    }
                    else
                    {
                        my $newlemma = $word;
                        print UNKNOWN "$line\t$txt\n";
                        $newlemma = lc($newlemma);
                        my $temp = "$word\t$pos\t$newlemma";
                        push(@newcontent, $temp);
                    }
                }
                elsif ($word eq '&amp')
                {
                    my $temp = '&amp;' . "\t" . 'CC' . "\t" . '&amp;';
                    push(@newcontent, $temp);
                    $ampflag = 1;
                }
                elsif ($lemma eq '<unknown>' && ($word eq "'M" || $word eq "'LL" || $word eq "'RE" || $word eq "'D" || $word eq "'VE"))
                {
                    my $newlemma = '';
                    my $newpos = '';
                    if ($word eq "'D" || $word eq "'LL" )
                    {
                        $newlemma = 'will';
                        $newpos = 'MD';
                    }
                    elsif ($word eq "'VE")
                    {
                        $newlemma = 'have';
                        $newpos = 'VBP';
                    }
                    else
                    {
                        $newlemma = 'be';
                        $newpos = 'VBP';
                    }
                    my $temp = "$word\t$newpos\t$newlemma";
                    print "Changed pos and lemma: $temp\n";
                    push(@newcontent, $temp);
                }
                elsif ($lemma eq '<unknown>')
                {
                    my $newlemma = $word;
                    print UNKNOWN "$line\t$txt\n";
                    $newlemma = lc($newlemma);
                    my $temp = "$word\t$pos\t$newlemma";
                    push(@newcontent, $temp);
                }
                else
                {
                    push(@newcontent, $line);
#                    print OUT "$line\n";
                }
            }
            else
            {
                push(@newcontent, $line);
#                print OUT "$line\n";
            }
            $previous = $line;
		}
        foreach (@newcontent)
        {
            print OUT "$_\n";
        }
        close(OUT);
	}
}
close(DS);
close(UNKNOWN);
print "No. files processed: $numFiles\n";
exit;

sub possibleNnumber
{
    my $numb = shift(@_);

    my $anumber = 1;

    my %hasj = (
        'one' => 'one',
        'two' => 'two',
        'three' => 'three',
        'four' => 'four',
        'five' => 'five',
        'six' => 'six',
        'seven' => 'seven',
        'eight' => 'eight',
        'nine' => 'nine',
        'ten' => 'ten',
        'twenty' => 'twenty',
        'thirty' => 'thirty',
        'fourty' => 'forty',
        'fifty' => 'fifty',
        'sixty' => 'sixty',
        'seventy' => 'seventy',
        'eighty' => 'eighty',
        'ninety' => 'ninety',
        'hundred' => 'hundred',
        'thousand' => 'thousand');

    my @numbers = split/-/, $numb;
    foreach my $xx (@numbers)
    {
        $xx = lc($xx);
        if (exists($hasj{$xx}))
        {
#            print "Exists: $xx\n";
        }
        else
        {
            $anumber = 0;
        }
    }

    return $anumber;
}