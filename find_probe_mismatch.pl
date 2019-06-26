#!/usr/bin/perl -w
use strict;
use warnings;
use File::Copy;
no warnings ('uninitialized', 'substr');

my ($probe_file, $sequences_file) = @ARGV;

my $report_file = 'report.txt';
my $left_seq = 'left_seq.txt';
my $tmp_seq = 'tmp_seq.txt';
my $clean_file = 'clean_seq.txt';

`grep -v '>' '$sequences_file' | perl -ne 'print lc' > $clean_file`; 
if(not defined $probe_file) {
   die "Need probe file\n";
}

if(not defined $sequences_file) {
   die "Need sequences file\n";
}

open(my $fh1, '<', $probe_file) 
        or die "Could not open file '$probe_file' $!";

open(my $fh2, '<', $sequences_file);

open(my $fh3, '>', $report_file) or die "Could not open file '$report_file' $!";

print $fh3 "Exclude only perfect match\n";
print $fh3 "-----------------------------------------------------------------------------------------------------------\n";
print $fh3 "|\t\t probe    \t|\t perfect match  |\t 1 mismatch |\t 2 mismatch |\t 3 mismatch \t|     Other \t|\n";




my $seq_header = "";
my $genome_seq = "";
my @genome;
my @probe;
my $index=0;
while(my $probe_seq = <$fh1>)
{
   chomp $probe_seq;
   $probe_seq = lc($probe_seq);
   $probe[$index++] = $probe_seq; 
}
for(my $j=0; $j < $index; $j++)
{

   if($j == 0)
   {
      find_1_2($probe[$j],$clean_file,$left_seq,$fh3,$tmp_seq);
   }
   else
   {
      find_1_2($probe[$j],$left_seq,$left_seq,$fh3,$tmp_seq);

   }

}

print $fh3 "-----------------------------------------------------------------------------------------------------------\n";

print $fh3 "Exclude perfect match and 1 mismatch\n";
print $fh3 "-------------------------------------------------------------------------------------------------\n";
print $fh3 "|\t probe    |\t perfect match  |\t 1 mismatch |\t 2 mismatch |\t 3 mismatch \t|     Other \t|\n";


for(my $j=0; $j < $index; $j++)
{

   if($j == 0)
   {
      find_mismatch($probe[$j],$clean_file,$left_seq,$fh3,$tmp_seq);
   }
   else
   {
      find_mismatch($probe[$j],$left_seq,$left_seq,$fh3,$tmp_seq);

   }


}

print $fh3 "-------------------------------------------------------------------------------------------------\n";



sub find_mismatch
{
   my($probe,$sequence,$left,$fh,$tmp) = @_;

    my $perfect = 0;
   my $mismatch_1 = 0;
   my $mismatch_2 = 0;
   my $mismatch_3 = 0;
   my $mismatch_other = 0;
   my $counter = 0;
   my $total = 0;
   open(my $fh4, '>', $tmp) or die "Could not open file '$tmp' $!";
   open(my $fh2, '<', $sequence);
   while(my $line = <$fh2>)
   {
      my $flag = 0;

      chomp $line;
      if(index($line,'>') != -1)
      {
         $seq_header = $line;
      }
      else
      {
         $total++;
         $genome_seq = $line;
         $genome_seq = lc($genome_seq);
        for(my $k=0; $k < length($genome_seq) - length($probe)+1; $k++)
        {
          for(my $i=0; $i < length($probe); $i++)
          {

             if(substr($probe, $i, 1) ne substr($genome_seq, $k+$i,1))
             {
               $counter++;
             }
          }
           if($counter == 0)
          {
             $perfect++;
             print $fh4 $genome_seq . "\n";
          }
          elsif($counter == 1)
          {
             $mismatch_1++;
             print $fh4 $genome_seq . "\n";
          }
          elsif($counter == 2)
          {
               $mismatch_2++;
          }
          elsif($counter == 3)
          {
               $mismatch_3++;
          }
          elsif($counter > 3)
          {
             if($flag == 0)
             {
               $mismatch_other++;
               $flag = 1;
             }
          }

          $counter = 0;
       }
     }
   }
  `grep -v -x -f $tmp  $sequence > 'extract.txt'`;
   print $mismatch_other . "\n";
   copy 'extract.txt', $left;


   print $fh "|" .  $probe . "|\t\t" .  $perfect . "   \t|\t" .  $mismatch_1 . " \t    |\t\t" . $mismatch_2 . "  |\t\t" . $mismatch_3 . "\t\t|\t" . ($total - $perfect - $mismatch_1 - $mismatch_2 - $mismatch_3) . "\t|\n";

   
}


sub find_1_2
{
   my($probe,$sequence,$left,$fh,$tmp) = @_;

    my $perfect = 0;
   my $mismatch_1 = 0;
   my $mismatch_2 = 0;
   my $mismatch_3 = 0;
   my $mismatch_other = 0;
   my $counter = 0;
   my $total = 0;
   open(my $fh4, '>', $tmp) or die "Could not open file '$tmp' $!";
   open(my $fh2, '<', $sequence);
   while(my $line = <$fh2>)
   {
      my $flag = 0;
      chomp $line;
      if(index($line,'>') != -1)
      {
         $seq_header = $line;
      }
      else
      {
         $total++;
         $counter = 0; 
         $genome_seq = $line;
         $genome_seq = lc($genome_seq);
        for(my $k=0; $k < length($genome_seq) - length($probe)+1; $k++)
        {
          for(my $i=0; $i < length($probe); $i++)
          {

             if(substr($probe, $i, 1) ne substr($genome_seq, $k+$i,1))
             {
               $counter++;
             }
          }

          if($counter == 0)
          {
             $perfect++;
             print $fh4 $genome_seq . "\n";
          }
          elsif($counter == 1)
          {
             $mismatch_1++;
          }
          elsif($counter == 2)
          {
               $mismatch_2++;
          }
          elsif($counter == 3)
          {
               $mismatch_3++;
          }
          elsif($counter > 3)
          {
             if($flag == 0)
             {
               $mismatch_other++;
               $flag = 1;
             }
          }
          $counter = 0;
       }
     }
   }

   `grep -v -x -f $tmp  $sequence > 'extract.txt'`;
   print $mismatch_other . "\n";
   copy 'extract.txt', $left;

   print $fh "|" .  $probe . "|\t\t" .  $perfect . "   \t|\t" .  $mismatch_1 . " \t    |\t\t" . $mismatch_2 . "  |\t\t" . $mismatch_3 . "\t\t|\t" . ($total - $perfect - $mismatch_1 - $mismatch_2 - $mismatch_3) . "\t|\n";
}
