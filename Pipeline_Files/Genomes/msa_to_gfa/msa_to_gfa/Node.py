class Node:
    """
    A node object to store the nodes' information
    """
    __slots__ = ['id', 'seq', 'out_nodes', 'in_nodes', 'colors']

    def __init__(self, identifier, seq=""):

        self.id = identifier
        self.seq = seq
        self.out_nodes = set()
        self.in_nodes = set()
        self.colors = set()

    def __key(self):
        return self.id

    def __hash__(self):
        return hash(self.__key())

    def __eq__(self, other):
        return self.__key() == other.__key()

    def __ne__(self, other):
        return not self.__eq__(other)

    def add_child(self, child):
        self.out_nodes.add(child)
        child.in_nodes.add(self)

    def remove_child(self, child):
        self.out_nodes.remove(child)
        child.in_nodes.remove(self)

    def add_parent(self, parent):
        self.in_nodes.add(parent)
        parent.out_nodes.add(self)

    def remove_parent(self, parent):
        self.in_nodes.remove(parent)
        parent.out_nodes.remove(self)

    def is_child_of(self, parent):
        if parent in self.in_nodes:
            return True
        return False

    def is_parent_of(self, child):
        if child in self.out_nodes:
            return True
        return False
