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
                elsif($lemma eq '<unknown>' && $word =~ /(.+)in$/)
                {
                    my $testifin = &ining($word);
                    if ($testifin eq '')
                    {
                        my $theoddword = &moreoddwords($word);
                        if ($theoddword eq '')
                        {
                            my $newlemma = $word;
                            print UNKNOWN "$line\t$txt\n";
                            $newlemma = lc($newlemma);
                            my $temp = "$word\t$pos\t$newlemma";
                            push(@newcontent, $temp);
                        }
                        else
                        {
                            print "Fixing in(g) extra: $theoddword\n";
                            push(@newcontent, $theoddword);
                        }
                    }
                    else
                    {
                        my $newlemma = $testifin;
                        my $newpos = 'VBG';
                        my $temp = "$word\t$newpos\t$newlemma";
                        print "Fixing in(g): $temp\n";
                        push(@newcontent, $temp);
                    }
                }
                elsif ($lemma eq '<unknown>')
                {
                    my $oddword = &oddwords($word);
                    if ($oddword eq '')
                    {
                        my $newlemma = $word;
                        print UNKNOWN "$line\t$txt\n";
                        $newlemma = lc($newlemma);
                        my $temp = "$word\t$pos\t$newlemma";
                        push(@newcontent, $temp);
                    }
                    else
                    {
                        print "Fixing odd words: $oddword\n";
                        push(@newcontent, $oddword);
                    }
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

sub ining
{

    my $ingword = shift(@_);

    my $returnvalue = '';

    my %hasj = (
	    'accordin' => 'accord',
	    'askin' => 'ask',
	    'avin' => 'have',
	    'bein' => 'be',
	    'bleedin' => 'bleed',
	    'blinkin' => 'blink',
	    'bloomin' => 'bloom',
	    'carryin' => 'carry',
	    'comin' => 'come',
	    'doin' => 'do',
	    'drinkin' => 'drink',
	    'drivin' => 'drive',
	    'eatin' => 'eat',
	    'expectin' => 'expect',
	    'feelin' => 'feel',
	    'findin' => 'find',
	    'fuckin' => 'fuck',
	    'gettin' => 'get',
	    'givin' => 'give',
	    'goin' => 'og',
	    'hangin' => 'hang',
	    'havin' => 'have',
	    'hearin' => 'hear',
	    'holdin' => 'hold',
	    'huntin' => 'hunt',
	    'keepin' => 'keep',
	    'laughin' => 'laugh',
	    'layin' => 'lay',
	    'leavin' => 'leave',
	    'lettin' => 'let',
	    'livin' => 'live',
	    'losin' => 'lose',
	    'lyin' => 'lie',
	    'makin' => 'make',
	    'marryin' => 'marry',
	    'payin' => 'pay',
	    'playin' => 'play',
	    'puttin' => 'put',
	    'readin' => 'read',
	    'runnin' => 'run',
	    'sayin' => 'say',
	    'seein' => 'see',
	    'settin' => 'set',
	    'shootin' => 'shoot',
	    'sittin' => 'sit',
	    'sleepin' => 'sleep',
	    'speakin' => 'speak',
	    'starin' => 'stare',
	    'stickin' => 'stick',
	    'talkin' => 'talk',
	    'tellin' => 'tell',
	    'thinkin' => 'think',
	    'tryin' => 'try',
	    'turnin' => 'turn',
	    'waitin' => 'wait',
	    'wantin' => 'want',
	    'wastin' => 'waste',
	    'watchin' => 'watch',
	    'wearin' => 'wear',
	    'wonderin' => 'wonder',
	    'worryin' => 'worry',
		'amazin' => 'amaze',
		'arguin' => 'argue',
		'beggin' => 'beg',
		'beginnin' => 'begin',
		'blowin' => 'blow',
		'boilin' => 'boil',
		'breathin' => 'breathe',
		'bringin' => 'bring',
		'buildin' => 'build',
		'burnin' => 'burn',
		'bustin' => 'bust',
		'callin' => 'call',
		'cookin' => 'cook',
		'crawlin' => 'crawl',
		'cryin' => 'cry',
		'cuttin' => 'cut',
		'dancin' => 'dance',
		'denyin' => 'deny',
		'diggin' => 'dig',
		'dinin' => 'dine',
		'dreamin' => 'dream',
		'dressin' => 'dress',
		'dyin' => 'die',
		'fallin' => 'fall',
		'fightin' => 'fight',
		'fishin' => 'fish',
		'fixin' => 'fix',
		'flyin' => 'fly',
		'grinnin' => 'grin',
		'growin' => 'grow',
		'helpin' => 'help',
		'hidin' => 'hide',
		'hittin' => 'hit',
		'hopin' => 'hope',
		'interferin' => 'interfer',
		'killin' => 'kill',
		'kissin' => 'kiss',
		'knockin' => 'knock',
		'knowin' => 'know',
		'listenin' => 'listen',
		'meanin' => 'mean',
		'meetin' => 'meet',
		'missin' => 'miss',
		'movin' => 'move',
		'muckin' => 'muck',
		'openin' => 'open',
		'packin' => 'pack',
		'passin' => 'pass',
		'pokin' => 'poke',
		'pretendin' => 'pretend',
		'pullin' => 'pull',
		'ridin' => 'ride',
		'ringin' => 'ring',
		'sellin' => 'sell',
		'sendin' => 'send',
		'singin' => 'sing',
		'smokin' => 'smoke',
		'spendin' => 'spend',
		'startin' => 'start',
		'starvin' => 'starve',
		'stayin' => 'stay',
		'stoppin' => 'stop',
		'sufferin' => 'suffer',
		'supposin' => 'suppose',
		'swearin' => 'swear',
		'tearin' => 'tear',
		'travellin' => 'travel',
		'usin' => 'use',
		'visitin' => 'visit',
		'wanderin' => 'wander',
		'warnin' => 'warn',
		'weddin' => 'web',
		'wishin' => 'wish',
	    'writin' => 'write');

    if (exists($hasj{$ingword}))
    {
        $returnvalue = $hasj{$ingword};
    }

    return $returnvalue;
}

sub oddwords
{
    my $localword = shift(@_);

    my $returnvalue = '';

    my %hasj = (
	    'aving' => "aving\tVBG\thave",
	    'couldna' => "couldna\tMD\tcould",
	    'usband' => "usband\tNN\thusband");

    if (exists($hasj{$localword}))
    {
        $returnvalue = $hasj{$localword};
    }

    return $returnvalue;
}

sub moreoddwords
{
    my $localword = shift(@_);

    my $returnvalue = '';

    my %hasj = (
	    'anythin' => "anythin\tNN\tanything",
	    'somethin' => "somethin\tNN\tsomething",
	    'nothin' => "nothin\tNN\tnothing",
	    'nuffin' => "nuffin\tNN\tnothing",
	    'everythin' => "everythin\tNN\teverything",
	    'evenin' => "evenin\tNN\tevening",
	    'shillin' => "shillin\tNN\tshilling",
	    'darlin' => "darlin\tNN\tdarling",
        'interestin' => "interestin\tJJ\tinteresting",
        'willin' => "willin\tJJ\twilling",
        'surprisin' => "surprisin\tJJ\tsurprise",
        'hein' => "hein\tIN\they",
	    'mornin' => "mornin\tNN\tmorning");

    if (exists($hasj{$localword}))
    {
        $returnvalue = $hasj{$localword};
    }

    return $returnvalue;
}


