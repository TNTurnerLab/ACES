wget --recursive --nH --no-parent -A '*-unmasked.fa.gz' ftp://ftp.ensembl.org/pub/rapid-release/species/ && find ./Genomes -iname '*-unmasked.fa.gz*' -exec mv '{}' ./Genomes  \; && gunzip *-unmasked.fa.gz