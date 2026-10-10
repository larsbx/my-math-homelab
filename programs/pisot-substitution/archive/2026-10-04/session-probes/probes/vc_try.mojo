from psc.vertex_coincidence import decide_vertex_coincidence

def main() raises:
    var specs = List[List[List[Int]]]()
    specs.append([[0, 1], [0, 2], [0]])
    specs.append([[1], [2, 2, 2], [0, 2, 2, 2]])
    specs.append([[1], [0, 2, 1], [0, 0, 1]])
    for i in range(len(specs)):
        print(decide_vertex_coincidence(specs[i]))
