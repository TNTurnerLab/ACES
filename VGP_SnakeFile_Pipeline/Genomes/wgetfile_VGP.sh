#!/bin/bash
wget --recursive --no-parent -A '*-unmasked.fa.gz' ftp://ftp.ensembl.org/pub/rapid-release/species/ && find ./ -iname '*-unmasked.fa.gz*' -exec mv '{}' ./  \; && gunzip *-unmasked.fa.gz
