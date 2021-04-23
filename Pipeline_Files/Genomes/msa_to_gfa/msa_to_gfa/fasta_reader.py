import gzip
import os
import logging
import sys
from collections import defaultdict


def read_fasta(fasta_file_path):
    """
    read fasta file and return a dict

    :return: a dictionary of seq_name:seq
    """

    sequences = defaultdict(str)
    if not os.path.exists(fasta_file_path):
        logging.error("file {} does not exist".format(fasta_file_path))
        sys.exit()

    if fasta_file_path.endswith("gz"):
        fasta_file = gzip.open(fasta_file_path, "rt")
    else:
        fasta_file = open(fasta_file_path, "r")

    seqs = []
    seq_name = ""
    for line in fasta_file:
        line = line.strip()
        if not line:  # empty line
            continue

        if line.startswith(">"):
            if len(seqs) != 0:  # there was a sequence before
                sequences[seq_name] = "".join(seqs)
                seq_name = line[1:]
                seqs = []
            else:
                seq_name = line[1:]
        else:
            seqs.append(line)

    if seqs:
        sequences[seq_name] = "".join(seqs)

    # check if all sequences have the same length
    seq_len = 0
    for seq_name, seq in sequences.items():
        if seq_len == 0:
            seq_len = len(seq)
        elif len(seq) != seq_len:
            logging.error("Sequence {} has a different length, abort".format(seq_name))
        else:
            continue

    return sequences
