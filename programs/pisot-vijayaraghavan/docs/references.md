# References

Imported results must be recorded as IMPORTED before they support a promoted
claim.

- D. W. Boyd: classical Pisot-sequence work, including nonrecurrent examples
  and the H=S framing.
- Desnanot–Jacobi / Dodgson determinant condensation.
- The exact fixed-size, every-late-shift bridge is proved directly in
  [Section 4 of the exponential-window note](exponential-window-hankel.md).
  It is not an imported claim or a use of the leading-minor formulation.
- Aitor Iribar Lopez, *The Carlson-Polya theorem on rational functions*,
  Section 2, Theorem 1, is background for Kronecker's leading Hankel
  determinant criterion (orders increasing at a fixed start). Inspected on
  October 5, 2026; not a proof dependency:
  <https://people.math.ethz.ch/~airibar/Polya_Carlson.pdf>.

## Imported dependency: square-summable approximation

Charles Pisot, *La répartition modulo 1 et les nombres algébriques*,
Annali della Scuola Normale Superiore di Pisa, Classe di Scienze, series 2,
**7**, no. 3-4 (1938), pp. 205-248. Chapter III, Theorem I: statement
on printed pp. 230-231, proof through p. 232 (PDF page indices 26-28).

- Primary article: <https://www.numdam.org/item/ASNSP_1938_2_7_3-4_205_0/>.
- Primary scan: <https://www.numdam.org/item/ASNSP_1938_2_7_3-4_205_0.pdf>.
- Inspected October 5, 2026. The integer specialization is recorded as
  PV-L2-RECURRENCE, **IMPORTED**, before use by PV-POLY-L2-RANGE.
- The given sequence may have arbitrary constant recurrence coefficients;
  no algebraicity of `alpha` is assumed in applying it to
  `u_n=lambda alpha^n`. The error must be square summable.
- The rational recurrence and Pisot endpoint used after this import are
  proved in the repository. The theorem is not used to infer recurrence
  from merely vanishing errors or an unverified boundary decay bound.
