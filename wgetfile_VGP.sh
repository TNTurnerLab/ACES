wget --recursive --no-parent -A '*-unmasked.fa.gz'  ftp://ftp.ensembl.org/pub/rapid-release/species/ && find /storage1/fs1/tychele/Active/projects/VGPGenomes/ -iname '*-unmasked.fa.gz*' -exec mv '{}' /storage1/fs1/tychele/Active/projects/VGPGenomes/  \; && gunzip *-unmasked.fa.gz