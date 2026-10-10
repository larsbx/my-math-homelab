# Derived contribution candidates

The theorems below are proved. Their use as research contributions remains
novelty-gated.

## N2-T02 — associator-defect operator

Under N2-T01, write
[
U_x=rac{L_x}{sqrt{N(x)}}in SO(8)
]
for every nonzero real division octonion (x). For nonzero (x,y), define
[
D(x,y)=U_xU_yU_{xy}^{-1}.
]

Then:

1. (D(x,y)in SO(8)).
2. (D(x,y)) fixes the unit vector (xy/sqrt{N(xy)}).
3. (D(x,y)=I) if and only if
   ([x,y,z]=x(yz)-(xy)z=0) for every (z).

**Proof.** The first assertion follows because (SO(8)) is a group. Let
(v=U_{xy}(1)=xy/sqrt{N(xy)}). Composition of the norm gives
(sqrt{N(xy)}=sqrt{N(x)}sqrt{N(y)}), so
[
D(x,y)v=U_xU_y(1)=rac{xy}{sqrt{N(x)}sqrt{N(y)}}=v.
]
Finally, (D(x,y)=I) exactly when (U_xU_y=U_{xy}). The normalization
scalars agree, so this is equivalent to (L_xL_y=L_{xy}), which evaluated at
arbitrary (z) is exactly (x(yz)=(xy)z). ∎

Thus the defect actually lies in the (SO(7)) stabilizer of the normalized
product direction. It provides an exact navigation observable even though
(xmapsto L_x) is not a homomorphism.

**Novelty boundary.** Multiplication operators, associators, (SO(8)), and
triality are classical. The candidate contribution is using this exact
stabilizer-valued defect as an arithmetic navigation and word-stratification
observable.

## N3-T02 — orbit-corrected collision moments

Let a finite group (G) act on a finite set (X), and let (r:X	o S) be
(G)-invariant. Put (X_s=r^{-1}(s)) and
(q_s=|X_s/G|). Since each (X_s) is (G)-stable, Burnside gives
[
q_s=rac1{|G|}sum_{gin G}|X_s^g|.
]

The induced map (ar r:X/G	o S) therefore has fiber sizes (q_s).
Applying N3-T01 to (ar r) gives
[
sum_{sin S}(q_s)_k
=
|{(O_1,ldots,O_k):
O_i	ext{ are distinct }G	ext{-orbits and }
ar r(O_1)=cdots=ar r(O_k)}|.
]

If the action is free, (q_s=m_s/|G|), and the left side becomes
[
sum_sprod_{j=0}^{k-1}left(rac{m_s}{|G|}-jight).
]
For a nonfree action the Burnside fixed-point table, not a guessed global
factor, is the exact correction. ∎

**Novelty boundary.** Burnside and factorial-moment counting are classical.
The candidate contribution is a machine-checkable stabilizer certificate
inserted between arithmetic shell enumeration and statistical inference.

## Cross-bridge candidate

N2-T02 and N3-T02 suggest **defect-stratified arithmetic navigation**:
reduce navigation words in a pinned integral model, attach an exact defect
class, and compute collision moments within each class. This could distinguish
mixing caused by the ambient matrix group from mixing obscured by
non-associative word defects. It remains a candidate until an integral
square-root-free invariant and a prior-art comparison are complete.
