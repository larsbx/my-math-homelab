---------------------------- MODULE MCFlippedTribonacci ----------------------------
(* Flipped Tribonacci: 1 |-> 21, 2 |-> 31, 3 |-> 1.  Same incidence matrix as
   Tribonacci, hence also PIP, but a different balanced-pair automaton.
   EXPECTED: all invariants hold. *)
EXTENDS BPA

SigmaDef == [a \in {1, 2, 3} |->
    CASE a = 1 -> <<2, 1>>
      [] a = 2 -> <<3, 1>>
      [] a = 3 -> <<1>>]
=============================================================================
