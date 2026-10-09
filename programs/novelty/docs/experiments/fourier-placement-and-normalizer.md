# Admissible Fourier placement and the normalizer reduction

**Status:** experimental result; no intrinsic uniqueness or novelty promotion.

## New finite witness

The original Phi=I+J placement fails replacement compatibility. This does
not imply failure at every bridge. Over F7 the character table F of the
additive group F2^3, with entries (-1) raised to the binary dot product,
satisfies F^T F=8I=I. Thus Phi F is another valid bridge.

The basis defects in octonion coordinates are the eight diagonal binary
characters. Fourier conjugation sends each diagonal character to a binary
translation permutation i maps to i xor t. Since Phi and Phi^-1 commute
with permutation matrices, transporting these to Descartes coordinates
leaves them permutation matrices. The eight placed defects are exactly the
eight binary translations. Every operator passes the quotient-adjacency
verifier, but all act as identity on unlabeled configurations.

This is an admissible placement with no new unframed navigation. It does
not select a unique placement. It also does not exclude signed permutation
placements or nonlinear automorphisms.

## Derivation of the normalizer reduction

For invertible configurations, quotient descent forces B Sigma_8 B^-1
to equal Sigma_8. Using the classical inner-automorphism theorem for S8,
such a B is P C with P a permutation and C commuting with all permutations.
Commutation makes the diagonal entries of C constant and its off-diagonal
entries constant, hence C=aI+bJ.

Over F7, the constant-vector subspace and coordinate-sum-zero subspace
are an orthogonal nondegenerate direct sum. The eigenvalues of C are
t=a+8b=a+b and a. Orthogonality requires a^2=t^2=1, leaving four cases.
The finite verifier accepts (a,t)=(1,1) and (6,6), and rejects (1,6)
and (6,1) for adjacency. Permutations preserve the replacement multigraph.
Thus, conditional on that normalizer classification, every admissible
left-linear action on the unlabeled full fiber is identity or scalar negation.

This derivation uses an imported classical classification; its general
normalizer theorem is not yet formalized in this repository. Concrete
Fourier identities are certified separately. There is no claim that the
finite graph has no other, nonlinear automorphisms.

## Verification

Run `python -m experiments.soddy.fourier_placement` and
`python -m unittest tests/test_fourier_placement.py -v`.
The tests compare the entire transported generator set with the independent
xor-translation matrices, rather than merely checking generator counts.
