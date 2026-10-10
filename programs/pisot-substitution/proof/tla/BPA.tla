--------------------------------- MODULE BPA ---------------------------------
(***************************************************************************)
(* The balanced-pair automaton B_sigma as a state machine.                 *)
(*                                                                         *)
(* A state of B_sigma is a balanced pair s = (u, v): two words of equal    *)
(* length with equal Parikh vectors.  The transition inflates both sides   *)
(* by sigma and cuts the result at every coincidence boundary.             *)
(*                                                                         *)
(* This module specifies the *construction* of B_sigma.  The variables     *)
(* range over the set of pairs discovered so far, so a terminating         *)
(* behaviour of this spec is exactly a finite B_sigma.                     *)
(*                                                                         *)
(* SCOPE.  Model checking this spec for a particular sigma establishes     *)
(* hypothesis G1 (finiteness of B_sigma) FOR THAT SIGMA ONLY, and only     *)
(* within the length bound MaxLen.  G1 for all primitive irreducible Pisot *)
(* substitutions on a 3-letter alphabet is OPEN: the predecessor-          *)
(* contraction proof of PSC_PROOF_v5 Theorem 5.1 is withdrawn.  A          *)
(* successful TLC run is elimination of counterexamples in scope, never a  *)
(* proof.                                                                  *)
(***************************************************************************)
EXTENDS Naturals, Sequences, FiniteSets

CONSTANTS
    Alphabet,   \* the letter set, e.g. {1, 2, 3}
    Sigma,      \* Sigma[a] is the image word of the letter a
    MaxLen,     \* length bound; exceeding it aborts the run as out of scope
    MaxRounds   \* bound on the number of breadth-first rounds

-----------------------------------------------------------------------------
(* Words and pairs *)

IsWord(w) ==
    /\ DOMAIN w = 1..Len(w)
    /\ \A i \in 1..Len(w) : w[i] \in Alphabet

IsPair(p) == IsWord(p[1]) /\ IsWord(p[2]) /\ Len(p[1]) = Len(p[2])

PrefixParikh(w, k) == [a \in Alphabet |-> Cardinality({i \in 1..k : w[i] = a})]

IsBalanced(p) ==
    /\ Len(p[1]) = Len(p[2])
    /\ PrefixParikh(p[1], Len(p[1])) = PrefixParikh(p[2], Len(p[2]))

IsCoincidence(p) == p[1] = p[2]

-----------------------------------------------------------------------------
(* Inflation *)

RECURSIVE Concat(_)
Concat(seqs) == IF seqs = << >> THEN << >> ELSE Head(seqs) \o Concat(Tail(seqs))

Inflate(w) == Concat([i \in 1..Len(w) |-> Sigma[w[i]]])

-----------------------------------------------------------------------------
(* Cutting at coincidence boundaries *)

Boundaries(u, v) == {k \in 0..Len(u) : PrefixParikh(u, k) = PrefixParikh(v, k)}

NextBoundary(u, v, k) ==
    CHOOSE m \in Boundaries(u, v) :
        /\ m > k
        /\ \A j \in Boundaries(u, v) : j > k => j >= m

RECURSIVE BlocksFrom(_, _, _)
BlocksFrom(u, v, k) ==
    IF k = Len(u)
    THEN << >>
    ELSE LET m == NextBoundary(u, v, k)
         IN << <<SubSeq(u, k + 1, m), SubSeq(v, k + 1, m)>> >> \o BlocksFrom(u, v, m)

Decompose(p) == BlocksFrom(p[1], p[2], 0)

-----------------------------------------------------------------------------
(* Normalisation: (u, v) and (v, u) are the same state *)

RECURSIVE LexLeq(_, _)
LexLeq(a, b) ==
    \/ Len(a) = 0
    \/ a[1] < b[1]
    \/ (a[1] = b[1] /\ LexLeq(Tail(a), Tail(b)))

Normalise(p) == IF LexLeq(p[1], p[2]) THEN p ELSE <<p[2], p[1]>>

ChildrenOf(p) ==
    LET blocks == Decompose(<<Inflate(p[1]), Inflate(p[2])>>)
    IN {Normalise(blocks[i]) : i \in 1..Len(blocks)}

SeedCandidates == {Normalise(<< <<a, b>>, <<b, a>> >>) : a \in Alphabet, b \in Alphabet}
Seeds == {p \in SeedCandidates : ~IsCoincidence(p)}

-----------------------------------------------------------------------------
(* The construction as a state machine *)

VARIABLES
    known,      \* every balanced pair discovered so far
    frontier,   \* those whose children have not yet been expanded
    edges,      \* the transition relation discovered so far
    overflow,   \* set when a pair longer than MaxLen appears
    rounds      \* breadth-first rounds completed

vars == <<known, frontier, edges, overflow, rounds>>

Init ==
    /\ known = Seeds
    /\ frontier = Seeds
    /\ edges = {}
    /\ overflow = FALSE
    /\ rounds = 0

(* One breadth-first round: expand the whole frontier at once.  Expanding
   states one at a time would make TLC enumerate every interleaving of a
   confluent computation; the fixpoint is the same and the round-based
   version keeps the state space linear in the number of rounds. *)
NewEdges ==
    UNION {{<<p, c>> : c \in ChildrenOf(p)} : p \in {q \in frontier : ~IsCoincidence(q)}}

Discovered == {e[2] : e \in NewEdges}

Step ==
    /\ frontier # {}
    /\ known' = known \cup Discovered
    /\ frontier' = Discovered \ known
    /\ edges' = edges \cup NewEdges
    /\ overflow' = overflow \/ (\E c \in Discovered : Len(c[1]) > MaxLen)
    /\ rounds' = rounds + 1

(* The construction halts by deadlock at the fixpoint, so model configurations
   must set CHECK_DEADLOCK FALSE: reaching the fixpoint is success, not a bug. *)
Next == Step

Spec == Init /\ [][Next]_vars /\ WF_vars(Next)

-----------------------------------------------------------------------------
(* Invariants *)

TypeOK ==
    /\ \A p \in known : IsPair(p)
    /\ frontier \subseteq known
    /\ edges \subseteq known \X known
    /\ overflow \in BOOLEAN
    /\ rounds \in Nat

(* Every reachable state is a balanced pair.  This is the K_1 = 0 statement:
   the Parikh vectors of the two sides agree, so the degree-1 horizontal
   invariant vanishes identically on B_sigma. *)
AllBalanced == \A p \in known : IsBalanced(p)

(* Cutting is length preserving: the children of p partition an inflation of p. *)
(* The construction never produced a pair longer than MaxLen, so the run is
   within scope and its verdict is meaningful. *)
NoOverflow == ~overflow

RECURSIVE SumSeq(_)
SumSeq(s) == IF s = << >> THEN 0 ELSE Head(s) + SumSeq(Tail(s))

(* Cutting at coincidence boundaries partitions the inflated word: the block
   lengths sum to the length of the inflation. *)
CuttingPreservesLength ==
    \A p \in known :
        ~IsCoincidence(p) =>
            LET su     == Inflate(p[1])
                blocks == Decompose(<<su, Inflate(p[2])>>)
            IN  SumSeq([i \in 1..Len(blocks) |-> Len(blocks[i][1])]) = Len(su)

(* Normalisation is idempotent and lands in the canonical orientation. *)
NormalIdempotent == \A p \in known : Normalise(p) = p

-----------------------------------------------------------------------------
(* Reachability at the fixpoint *)

Succ(S) == S \cup {q \in known : \E p \in S : <<p, q>> \in edges}

RECURSIVE Iterate(_, _)
Iterate(S, n) == IF n = 0 THEN S ELSE Iterate(Succ(S), n - 1)

ReachSet(p) == Iterate({p}, Cardinality(known))

(***************************************************************************)
(* Productivity: every discovered balanced pair reaches a coincidence.      *)
(*                                                                         *)
(* This is the SCC Producer conjecture (conj:producer) restricted to the    *)
(* reachable part of B_sigma for one sigma.  It is CONJECTURAL in general;  *)
(* TLC checking it here eliminates counterexamples for this sigma only.     *)
(***************************************************************************)
Productive ==
    frontier = {} => \A p \in known : \E q \in ReachSet(p) : IsCoincidence(q)

(***************************************************************************)
(* Termination of the construction, i.e. finiteness of the reachable part   *)
(* of B_sigma.  This is hypothesis G1 for this sigma, within the bounds.    *)
(*                                                                          *)
(* Step is a deterministic function of the state and is enabled exactly     *)
(* while the frontier is non-empty, so the spec has a single behaviour.     *)
(* If this invariant holds on every reachable state then that behaviour     *)
(* performs fewer than MaxRounds rounds and halts with an empty frontier -- *)
(* which is termination.  Stating it as safety rather than as <>(frontier   *)
(* = {}) keeps it inside TLC's model-checking mode, and loses nothing here. *)
(***************************************************************************)
TerminatesInBound == rounds < MaxRounds \/ frontier = {}

=============================================================================
