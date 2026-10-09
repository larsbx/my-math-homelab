---------------------------- MODULE MCTribonacci ----------------------------
(* Tribonacci: 1 |-> 12, 2 |-> 13, 3 |-> 1.  Incidence matrix
   [[1,1,1],[1,0,0],[0,1,0]] is primitive with irreducible characteristic
   cubic t^3 - t^2 - t - 1 and Pisot Perron root, so sigma is PIP.
   EXPECTED: all invariants hold. *)
EXTENDS BPA

SigmaDef == [a \in {1, 2, 3} |->
    CASE a = 1 -> <<1, 2>>
      [] a = 2 -> <<1, 3>>
      [] a = 3 -> <<1>>]
=============================================================================
