#!bin/bash

clustalo -i rpoa_random_sequences.fasta -o rpoa_random_sequences.aln --threads 10 --distmat-out=rpoa_random_sequences.mat --force --full --percent-id

# creating the tsv
grep ">" rpoa_random_sequences.fasta | awk '{print substr($0, 2) "\t" substr($1,2)}' > seq_names.tsv

# command for runinng msa_to_gfa
../main.py -f rpoa_random_sequences.aln -o rpoa_random_sequences.gfa -n seq_names.tsv --log rpoa_random_sequences.log
