"""A deterministic pseudo-random source for exploratory sweeps.

`SplitMix64` is the standard 64-bit mixing generator: the state advances by a
fixed odd increment and the output is an avalanche of the state. It is chosen
because it is exactly specified by three shifts and two multiplications, so a
sweep is reproducible from its seed alone, on any machine, with no dependency
on a library's generator.

Randomness enters this repository only in exploratory searches. No certificate,
census or proof-support computation may depend on it: an exact statement is
decided over a stated finite domain, never sampled.
"""

comptime GOLDEN_GAMMA = 0x9E3779B97F4A7C15
comptime MIX_A = 0xBF58476D1CE4E5B9
comptime MIX_B = 0x94D049BB133111EB


struct SplitMix64(Copyable, Movable):
    var state: UInt64

    def __init__(out self, seed: Int):
        self.state = UInt64(seed)

    def next_bits(mut self) -> UInt64:
        """One 64-bit output; the generator's full period is `2^64`."""
        self.state += GOLDEN_GAMMA
        var z = self.state
        z = (z ^ (z >> 30)) * MIX_A
        z = (z ^ (z >> 27)) * MIX_B
        return z ^ (z >> 31)

    def below(mut self, bound: Int) raises -> Int:
        """A value in `0 .. bound-1`, rejecting the unbalanced tail so that
        every value is equally likely (Lemire's rejection bound)."""
        if bound <= 0:
            raise Error("random bound must be positive")
        var limit = UInt64.MAX - (UInt64.MAX % UInt64(bound))
        var draw = self.next_bits()
        while draw >= limit:
            draw = self.next_bits()
        return Int(draw % UInt64(bound))

    def between(mut self, low: Int, high: Int) raises -> Int:
        """A value in the inclusive range `low .. high`."""
        if high < low:
            raise Error("random range is empty")
        return low + self.below(high - low + 1)

    def choice(mut self, values: List[Int]) raises -> Int:
        return values[self.below(len(values))]
