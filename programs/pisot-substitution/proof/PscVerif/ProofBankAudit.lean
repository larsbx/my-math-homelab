/- Replay this file with `lake env lean ProofBankAudit.lean`, not as a cached
library target. Inspect every compiled declaration in every PscVerif module,
including definitions and generated helpers, not just a selected theorem list. -/
import PscVerif
import Lean.Util.CollectAxioms

open Lean Elab Command in
run_cmd do
  let env ← getEnv
  let mut count := 0
  let mut theorems := 0
  let allowed := #[`propext, `Classical.choice, `Quot.sound]
  for (name, info) in env.constants.toList do
    let some idx := env.getModuleIdxFor? name | continue
    let mod := env.header.moduleNames[idx.toNat]!
    if mod.getRoot != `PscVerif then continue
    if info.isAxiom then
      throwError "Local axiom in the proof bank: {name}"
    let axioms ← collectAxioms name
    for ax in axioms do
      if !allowed.contains ax then
        throwError "Nonstandard axiom in {name}: {ax}"
    count := count + 1
    if info.isTheorem then theorems := theorems + 1
    let kind := if info.isTheorem then "theorem" else "declaration"
    let userName := privateToUserName name
    let names := String.intercalate "," (axioms.toList.map toString)
    liftIO <| IO.println s!"PSC_AXIOMS\t{kind}\t{mod}\t{name}\t{userName}\t{names}"
  if theorems == 0 then throwError "The proof bank contains no theorems"
  liftIO <| IO.println s!"PSC_AUDIT_COMPLETE\t{count}\t{theorems}"
