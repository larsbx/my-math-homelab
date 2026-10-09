---------------------------- MODULE MCNonProductive ----------------------------
(* NEGATIVE CONTROL.  1 |-> 2, 2 |-> 123, 3 |-> 2 is primitive but NOT Pisot:
   its incidence matrix has characteristic cubic with a root of modulus > 1
   besides the Perron root.  Some reachable balanced pair never reaches a
   coincidence.
   EXPECTED: Productive is VIOLATED.  This is what makes the positive runs
   meaningful -- the invariant is not vacuously true. *)
EXTENDS BPA

SigmaDef == [a \in {1, 2, 3} |->
    CASE a = 1 -> <<2>>
      [] a = 2 -> <<1, 2, 3>>
      [] a = 3 -> <<2>>]
=============================================================================
