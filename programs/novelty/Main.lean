import NoveltyLab.SelfCheck
import NoveltyLab.IntrinsicSelectionF7
import NoveltyLab.FourierPlacementF7

open NoveltyLab.SelfCheck in
def main : IO Unit := do
  for (name, ok) in checks do
    IO.println s!"{if ok then "ok  " else "FAIL"} {name}"
  if selfCheck then
    IO.println s!"Lean oracle self-check passed ({checks.length} checks)"
  else
    throw (IO.userError "Lean oracle self-check failed")
