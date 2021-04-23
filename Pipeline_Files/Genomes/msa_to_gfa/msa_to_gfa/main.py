#!/usr/bin/env python3
import sys
import os
import time
import argparse
import logging
from fasta_reader import read_fasta
from msa_to_gfa import msa_graph
from write_gfa import write_gfa


parser = argparse.ArgumentParser(description='Build GFA v1 from MSA given in FASTA format')

parser.add_argument("-f", "--in_msa", metavar="MSA_PATH", dest="in_msa",
                    default=None, type=str, help="Input MSA in FASTA format")

parser.add_argument("--compact", dest="compact",
                    action="store_true", help="If this give, the graph will be compacted before writing")

parser.add_argument("-o", "--out", metavar="OUT_GFA", dest="out_gfa",
                    default="gfa_out.gfa", type=str, help="Output GFA name/path")

parser.add_argument("-n", "--seq_name_tsv", metavar="SEQ_NAMES", dest="seq_names",
                    default=None, type=str, help="A tsv with two columns, first is sequence names"
                                                 ", second is a shortened or abbreviated name")

parser.add_argument("-c", "--nodes_info", metavar="COLORS", dest="nodes_dict",
                    default=None, type=str, help="Output JSON file with nodes information")

parser.add_argument("--log", metavar="LOG_FILE", dest="log_file",
                    default=None, type=str, help="Log file name/path. Default = out_log.log")
args = parser.parse_args()


def main():

    if len(sys.argv) < 2:
        print("You need to provide inputs. try -h or --help for help")
        sys.exit()

    # Log file stuff
    if not args.log_file:
        log_file = "out_log.log"
    else:
        log_file = args.log_file

    logging.basicConfig(filename=log_file, filemode='w',
                        format='[%(asctime)s] %(message)s',
                        level=getattr(logging, "INFO"))

    # taking fasta file
    if args.in_msa:
        sequences = read_fasta(args.in_msa)
    else:
        logging.error("You did not provide input msa file, -f, check -h for help")
        sys.exit()

    # reading sequence names if provided
    seq_names = dict()
    if args.seq_names:
        if os.path.exists(args.seq_names):
            with open(args.seq_names) as in_file:
                for raw_l in in_file:
                    line = raw_l.strip().split("\t")
                    if line[0] not in sequences:
                        logging.error("The sequence {} in file {} does not exist in the "
                                      "fasta file {} provided".format(line[0], args.seq_names, args.in_msa))
                    else:
                        seq_names[line[0]] = line[1]
        else:
            logging.error("File {} provided as sequence names tsv does not exist".format(args.seq_names))

    else:
        for key in sequences.keys():
            seq_names[key] = key

    # building graph
    logging.info("constructing graph...")
    graph = msa_graph(sequences, seq_names)
    graph.colors = seq_names

    if args.compact:
        logging.info("compacting linear paths in graph...")
        # Compacting just merges stretches of single nodes together
        graph.compact()

    logging.info("sorting the graph toplogocially...")
    # I use topological sorting to write the paths in order
    graph.sort()  # topological sorting
    logging.info("adding paths to graph...")
    graph.add_paths()  # adds paths to graph
    logging.info("writing graph...")

    write_gfa(graph, args.out_gfa)  # outputting
    if args.nodes_dict:
        logging.info("writing nodes info json file...")
        graph.nodes_info(args.nodes_dict)
    logging.info("finished...")


if __name__ == "__main__":
    main()
