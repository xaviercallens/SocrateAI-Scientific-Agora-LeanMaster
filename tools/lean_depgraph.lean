/-
tools/lean_depgraph.lean — kernel-level dependency dump (used by tools/theorem_atlas.py).

For every constant declared in this project's own modules, print one JSON line with the
constants its *statement* (type) uses and the constants its *proof/body* (value) uses.
Unlike the regex-based `leangraph`, this reads the elaborated environment, so an edge exists
exactly when the kernel term really mentions the other constant.

Run:  lake env lean tools/lean_depgraph.lean > .leancache/depgraph.jsonl
-/
import DualScaleStream2
import StringTheoryFormalization
import DoubleFieldTheory
import DualScaleM24Formalization
import StringTheoryFoundation
import DualScaleValidation
import Lean5Corpus

open Lean

def ownRoots : List Name :=
  [`DualScaleStream2, `StringTheoryFormalization, `DoubleFieldTheory,
   `DualScaleM24Formalization, `StringTheoryFoundation, `DualScaleValidation, `Lean5Corpus]

def jsonStr (s : String) : String := (toJson s).compress

def namesJson (ns : Array Name) : String :=
  "[" ++ ",".intercalate (ns.toList.map fun n => jsonStr n.toString) ++ "]"

run_cmd do
  let env ← getEnv
  let mods := env.header.moduleNames
  for (c, info) in env.constants.map₁.toList do
    if c.isInternal then continue
    let some idx := env.getModuleIdxFor? c | continue
    let m := mods[idx.toNat]!
    unless ownRoots.any (fun r => r.isPrefixOf m) do continue
    let kind := match info with
      | .thmInfo _ => "theorem" | .defnInfo _ => "def" | .axiomInfo _ => "axiom"
      | .inductInfo _ => "inductive" | .ctorInfo _ => "ctor" | .recInfo _ => "rec"
      | .opaqueInfo _ => "opaque" | .quotInfo _ => "quot"
    if kind == "ctor" || kind == "rec" then continue
    let tyC := info.type.getUsedConstants
    let valC := match info with
      | .thmInfo t => t.value.getUsedConstants
      | .defnInfo d => d.value.getUsedConstants
      | _ => #[]
    -- external *lemmas* only (theorems of Mathlib/core), so that shared foundations are not
    -- drowned by notation constants such as `Neg.neg` or `LE.le`
    let lemmas := valC.filter fun d =>
      (match env.find? d with | some (.thmInfo _) => true | _ => false) &&
      (match env.getModuleIdxFor? d with
        | some i => !(ownRoots.any fun r => r.isPrefixOf mods[i.toNat]!)
        | none => false)
    IO.println s!"\{\"name\":{jsonStr c.toString},\"lemmas\":{namesJson lemmas},\"module\":{jsonStr m.toString},\"kind\":\"{kind}\",\"type\":{namesJson tyC},\"value\":{namesJson valC}}"
