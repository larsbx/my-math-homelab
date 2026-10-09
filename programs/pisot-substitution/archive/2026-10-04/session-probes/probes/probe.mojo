from psc.one_tile import mirror, one_tile
def s3(a: List[Int], b: List[Int], c: List[Int]) -> List[List[Int]]:
    var x = List[List[Int]]()
    x.append(a.copy()); x.append(b.copy()); x.append(c.copy())
    return x^
def main() raises:
    print(one_tile(mirror(s3([1], [0, 1, 2], [0, 1, 0]))))
    print(one_tile(mirror(s3([1], [1, 2], [0, 2, 2]))))
    print(one_tile(mirror(s3([0, 1], [0, 2], [0]))))
