from Node import Node


def copy_connections(graph):
    """
    returns a dictionary with a copy of the graph's edges and nodes

    :param graph: a graph object
    :return nodes: dictionary of node objects and their connections
    """
    nodes = dict()
    for n in graph.nodes.values():
        new_node = Node(n.id)
        new_node.in_nodes = set([x.id for x in n.in_nodes])
        new_node.out_nodes = set([x.id for x in n.out_nodes])
        nodes[new_node.id] = new_node
    return nodes


def top_sorting(graph):
    """
    Returns a list of topologically-sorted nodes. Performs Kahn's algorithm
    pseudo code from https://en.wikipedia.org/wiki/Topological_sorting

    :param graph: a grpah object
    :return: a list of sorted nodes
    """

    # Kahn's algorithm needs to remove edges
    # The easiest way was to make a deep copy of the graph
    # If later I find this too problematic, I'll try the DFS based algorithm

    # new_graph = copy.deepcopy(graph)
    # For some reason I cannot call deepcopy on my graph
    # there seems to be a problem with deep copy in python3
    # it runs an infinite recursion and runs out of stack
    # many stackoverflow posts talked about this problem

    # so I'll just make a simple dictionary with the connections
    # and use that to sort (less memory anyway than copying the whole graph)

    nodes = copy_connections(graph)
    sorted_nodes = []
    starting_nodes = set()

    # getting starting nodes (nodes with no incoming edges)
    for n in nodes.values():
        if not n.in_nodes:
            starting_nodes.add(n.id)

    while starting_nodes:
        node_id = starting_nodes.pop()
        sorted_nodes.append(node_id)
        children = list(nodes[node_id].out_nodes)
        for child in children:
            # removing edge
            nodes[node_id].out_nodes.remove(child)
            nodes[child].in_nodes.remove(node_id)

            # if child has no more parents
            # add to starting nodes set
            if not nodes[child].in_nodes:
                starting_nodes.add(child)

    # if there is one or more edge left
    # then the graph is not DAG (or some other problem happened)
    for n in nodes.values():
        if n.in_nodes:
            return []

    else:
        return sorted_nodes
