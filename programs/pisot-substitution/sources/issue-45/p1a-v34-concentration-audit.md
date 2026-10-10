# P1-A audit — what v34 proves and what concentration still owes

**Status:** proof-source audit for issue #43. This note does not prove aux-B.

## 1. Valid v34 input

The archived `DOMINANT_K2_SOURCE_V34.md` / `V34_CLOSURE.md` contain a valid structural source lemma independent of the withdrawn predecessor-contraction argument:

- the three length-two swap pairs have `K2` vectors equal to the standard basis of `Lambda^2 Z^3`;
- the dominant spectral projection of `Lambda^2 M_sigma` is nonzero;
- therefore at least one length-two balanced pair has nonzero dominant `K2` projection.

With G1 supplied as an **assumption**, inter-block cancellation plus finite path counting yields the historical load-bearing conclusion:

> some recurrent noncoincident SCC carries spectral growth at least `beta |beta_2|`.

This is useful input to P1-A.

## 2. What it does not prove

The v34 capture argument is global over the finite reachable graph. It forces dominant mass into **some recurrent SCC** after transient contributions are exhausted.

The contradiction route now needs something stronger:

> dominant expanding wedge contribution has nonzero projection in the particular **closed recurrent nonproductive carrier** extracted from global nonproductivity.

Those are different statements.

A recurrent SCC found by global path counting may:

- have an exit;
- be productive;
- be unrelated to the sink component inside the forward-closed nonproductive set.

Thus the old “some recurrent SCC carries dominant growth” theorem cannot be substituted for concentration / aux-B.

## 3. The exact missing transport problem

Let `NP` be the forward-closed nonproductive state set and let `C` be a sink SCC of the induced graph on `NP`.

P1-A must control how dominant wedge mass moves through the SCC condensation graph strongly enough to show that, if nonproductivity persists, a nonzero dominant component survives in an appropriate closed recurrent carrier.

A valid proof could take one of several forms, but it must explicitly rule out the escape mechanism:

```text
dominant source
-> transient/recurrent decomposition
-> all dominant contribution captured by productive or escaping carriers
-> strict sink C receives zero dominant projection.
```

Simply proving that the total recurrent part is nonzero does not rule this out.

## 4. Stale archive claims to quarantine

`archive/2026-09-08/certificates_patched/V34_CLOSURE.md` contains internally inconsistent historical status text.

Early sections correctly say:

- v5 Theorem 5.1 is withdrawn;
- finite `B_sigma` is hypothesis G1;
- the load-bearing SCC theorem is conditional on G1.

Later preserved sections still say, for example:

- finite `B_sigma` is proved by v5 Theorem 5.1;
- the load-bearing SCC theorem is unconditional;
- all hypotheses are discharged.

Those later lines are archival residue and must not be cited as current proof status. The 2026-09-11 ledger and the withdrawal notice control.

## 5. Relation to the new concentration/Galois route

The weekly completion ledger reports a later improvement:

```text
closed recurrent carrier
+ concentration / aux-B
=> phi_dom != 0
=> Galois propagation
=> full wedge span
=> productivity.
```

The Galois step reduces the nonvanishing burden, but it does not supply concentration itself.

Therefore the useful inheritance from v34 is:

1. an explicit finite family of dominant wedge sources;
2. exact inter-block cancellation / additive transport;
3. a finite-graph recurrent-capture template under G1;
4. concrete evidence about where a concentration proof must strengthen that template.

## 6. P1-A proof obligations sharpened

A successful aux-B proof should answer all of the following.

1. **Carrier selection.** Which closed recurrent carrier is being targeted, and how is it related to the sink SCC of the nonproductive subgraph?
2. **Mass transport.** What exact additive or signed quantity transports through child decomposition?
3. **No-escape lemma.** Why can the dominant component not be exhausted entirely by transient, productive, or escaping SCCs?
4. **Noncancellation.** If several paths feed the carrier, what prevents cancellation of the dominant functional there?
5. **No hidden G1b-2 use.** The proof may assume finite BPA through G1 but may not re-prove or import renewal finiteness inside aux-B.
6. **Convention match.** The imported later Galois proof must use the same signed/unsigned wedge convention as the current repository; normalized defect transfer is signed where orientation requires it.

## 7. Executable next step

A useful Mojo diagnostic should work on the SCC condensation DAG and record exact dominant-wedge transfer by carrier, distinguishing:

- transient SCCs;
- recurrent SCCs with exits;
- productive recurrent SCCs;
- closed nonproductive SCC candidates.

Its purpose is to falsify overstrong concentration statements and identify the weakest no-escape statement compatible with all exact finite specimens. It is not itself a proof of concentration.
