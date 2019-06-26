#!/usr/bin/perl -w
use strict;
use warnings;
#
my $input_file = $ARGV[0];
`dos2unix $input_file`;
my $output_file =  "clean.fa";

open(my $fh1, '<', $input_file)
        or die "Could not open file '$input_file' $!";
open(my $fh2, '>', $output_file)
        or die "Could not open file '$output_file' $!";

my $flag=0;
my $seq = '';
my $line=<$fh1>;
chomp $line;
print $fh2 $line . "\n";
while(my $line = <$fh1>)
{
    chomp $line;
    if(index($line,'>') != -1)
    {
        if($seq ne '')
        {
           print $fh2 $seq . "\n";
           $seq = '';
        }
        print $fh2 $line . "\n";
    }
    else
    {
      $seq = $seq . $line;
    } 
}
 print $fh2 $seq . "\n";
close $fh1;
close $fh2;
