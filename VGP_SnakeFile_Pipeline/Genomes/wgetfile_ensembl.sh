#!/bin/bash
wget --recursive --no-parent -A '*.dna.toplevel.fa.gz' ftp://ftp.ensembl.org/pub/release-103/fasta/ && find ./Genomes -iname '*.dna.toplevel.fa.gz' -exec mv '{}' ./Genomes  \; && gunzip *.dna.toplevel.fa.gz
