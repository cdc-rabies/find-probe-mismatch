# find-probe-mismatch
This is a Perl script to find the number of mismatch probes against a given fasta sequence.

This script is tested in CentOs 7.

The steps to run the scripts:
1. perl clean_raw_data.pl <fasta sequence file>, will created the concatenated fasta sequence file: clean.fa
2. perl find_probe_mismatch.pl  <probe file> clean.fa, will created the final report about perfect match, 1 mismatch, 2 mismatch, 3 mismatch and other (> 3 mismatch).
