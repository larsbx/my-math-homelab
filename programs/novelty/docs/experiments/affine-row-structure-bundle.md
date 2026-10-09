# Retaining the translation law without choosing a frame

**Status:** experimental result; exact finite enumeration, not Lean-certified.

The Fourier placement exposes a translation group F2^3 on the eight rows.
After forgetting all row structure, it becomes invisible. To retain its
composition law, consider every affine F2^3 structure on the row set.
An affine structure is additional data, not a consequence of the packing
Gram identities.

The standard structure has 14 affine planes: four-element subsets whose
binary xor is zero. Relabeling these planes through all 8! permutations
produces exactly 30 distinct structures. Their stabilizer has order 1344.
The entire family is invariant under relabeling; none of its members has
been distinguished by an intrinsic packing criterion.

Each structure defines a ternary operation T(a,b,c), the unique fourth
element of a plane when the inputs are distinct; repeated inputs cancel.
For an origin o and target t, the permutation v maps to T(o,t,v) is a
translation. The set of eight translations is independent of origin.
It is an elementary abelian group: composition is closed, commutative,
and every member squares to identity.

A decorated configuration consists of (W, affine structure, marked row),
modulo simultaneous row relabeling. There are 30 structures and 8 marked
rows per labeled configuration, giving 240 decorations. Translations act
on the marked row while leaving W and its affine structure unchanged.
They form a group bundle: relabeling transports each local translation
group. No globally chosen generators or preferred origin are asserted.

This is nontrivial internal navigation on decorated states, not a new
action on the underlying unlabeled packing. Forgetting the decoration
still makes all these translations invisible. The replacement relation
can carry the row structure along while replacing the indexed row; its
equivariance uses the same simultaneous relabeling as the previous model.
That decorated replacement graph is a specification here, not implemented
or Lean-certified by this experiment.

The tests enumerate every relabeled affine structure, check every local
translation group and every origin, compare ternary completion with an
independent xor reference, and verify adjacent-transposition equivariance.
Neither this affine family nor its local groups specify an octonion
multiplication tensor. Recovering an intrinsic octonionic decoration or
selecting one structure from packing relations remains open.

Run `python -m experiments.soddy.affine_row_structures` and
`python -m unittest tests/test_affine_row_structures.py -v`.
