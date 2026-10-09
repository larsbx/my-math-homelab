"""A bounded exact histogram over non-negative integer keys.

Census drivers tabulate depths, discrepancies and bounds per specimen or per
vertex. The capacity is fixed up front and a key outside it raises: a census
statistic that outgrows its table is an event to report, never a silent
truncation. `line` renders the census format `label k:count k:count ...`,
listing only the keys that occur.
"""


struct Histogram(Copyable, Movable):
    var counts: List[Int]

    def __init__(out self, capacity: Int = 128):
        self.counts = List[Int](length=capacity, fill=0)

    def record(mut self, key: Int) raises:
        if key < 0 or key >= len(self.counts):
            raise Error(
                "histogram key " + String(key) + " lies outside 0.."
                + String(len(self.counts) - 1)
            )
        self.counts[key] += 1

    def count(self, key: Int) -> Int:
        return self.counts[key] if key >= 0 and key < len(self.counts) else 0

    def maximum(self) -> Int:
        """Largest recorded key; `0` when nothing has been recorded."""
        for key in range(len(self.counts) - 1, -1, -1):
            if self.counts[key] > 0:
                return key
        return 0

    def total(self) -> Int:
        var n = 0
        for key in range(len(self.counts)):
            n += self.counts[key]
        return n

    def line(self, label: String) -> String:
        var out = label
        for key in range(len(self.counts)):
            if self.counts[key] > 0:
                out += " " + String(key) + ":" + String(self.counts[key])
        return out


def max_int(a: Int, b: Int) -> Int:
    return a if a >= b else b


def min_int(a: Int, b: Int) -> Int:
    return a if a <= b else b
