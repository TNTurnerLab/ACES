import logging
import sys
from topological_sorting import top_sorting
from compact import compact_graph
import json


class Graph:
    __slots__ = ['nodes', 'paths', 'sorted', 'colors']

    def __init__(self, nodes):
        self.nodes = nodes
        self.paths = dict()
        self.sorted = []
        self.colors = dict()

    def __len__(self):
        return len(self.nodes)

    def __getitem__(self, item):
        if item in self.nodes:
            return self.nodes[item]
        else:
            print("Node {} is not in the graph")
            return None

    def __str__(self):
        for n in self.nodes.values():
            for nn in n.out_nodes:
                print("{} {} --> {} {}".format(n.id, n.seq, nn.seq, nn.id))

    def sort(self):
        if not self.sorted:
            self.sorted = top_sorting(self)
            if not self.sorted:
                logging.error("The graph cannot be topologically sorted")
                sys.exit()
            elif len(self.sorted) != len(self.nodes):
                logging.error("The sorted list of nodes does not equal the number of nodes \n"
                              "Something went wrong, investigate please!")
                sys.exit()
        else:
            pass

    def compact(self):
        compact_graph(self, )

    def add_paths(self):
        if not self.sorted:
            self.sort()

        for n in self.sorted:
            for color in self.nodes[n].colors:
                if color not in self.paths:
                    self.paths[color] = [n]
                else:
                    self.paths[color].append(n)

    def nodes_info(self, output_file):
        out_file = open(output_file, "w")
        for n in self.nodes.values():
            node_info = {"id": n.id, "colors": list(n.colors), "seq": n.seq}
            out_file.write(json.dumps(node_info) + "\n")
        out_file.close()
