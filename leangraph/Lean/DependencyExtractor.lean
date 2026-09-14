import Lean
import Lean.Data.Json.FromToJson
import Lean.Elab.BuiltinCommand
import Lean.Meta.Basic
import Lean.Message

open Lean Elab Term Meta

/-!
# LeanGraph Native Metaprogramming Dependency Extractor
Directly inspects Lean's compiled kernel environment (`CoreM` / `TermElabM`).
Walks `Lean.Environment.constants`, `Expr.getUsedConstants`, and structures.
Inspired by:
- patrik-cihal/lean-graph/static/DependencyExtractor.lean
- aurasoph/lean-graph/LeanGraph/Graph/ProofDeps.lean
-/

namespace LeanGraph.Native

/-- Convert declaration type to category string -/
def getConstCategory (n : Name) : TermElabM String := do
  let constInfo ← getConstInfo n
  return match constInfo with
    | ConstantInfo.defnInfo _   => "def"
    | ConstantInfo.thmInfo _    => "theorem"
    | ConstantInfo.axiomInfo _  => "axiom"
    | ConstantInfo.inductInfo _ => "inductive"
    | ConstantInfo.ctorInfo _   => "constructor"
    | ConstantInfo.recInfo _    => "recursor"
    | _                         => "other"

/-- Extract used constants from proof body or definition value -/
def getDirectDependencies (n : Name) (keepInstances := false) (keepTheorems := true) :
    TermElabM (Array Name) := do
  let constInfo ← getConstInfo n
  let body := match constInfo with
    | ConstantInfo.thmInfo val => some val.value
    | ConstantInfo.defnInfo val => some val.value
    | _ => constInfo.value?
  let consts := match body with | some b => b.getUsedConstants | none => #[]
  let filtered ← consts.filterM fun m => do
    let info ← getConstInfo m
    let inst ← isInstance m
    pure <|
      (match info with
       | ConstantInfo.defnInfo _  => true
       | ConstantInfo.axiomInfo _ => true
       | ConstantInfo.thmInfo _   => keepTheorems
       | _                        => false) &&
      (keepInstances || !inst) &&
      (!m.isInternal)
  return filtered

/-- Breadth-first search dependency traversal up to specified depth -/
structure BFSState where
  visited : List (Name × List Name)
  frontier : List Name

def extractBFSSubgraph (roots : List Name) (depth : Nat) : TermElabM (List (Name × List Name)) := do
  let mut visited : List (Name × List Name) := []
  let mut frontier := roots
  for _ in [0:depth] do
    let mut nextFrontier : List Name := []
    for name in frontier do
      if !visited.any (fun (n, _) => n == name) then
        let deps ← try getDirectDependencies name catch | _ => pure #[]
        let depsList := deps.toList
        visited := (name, depsList) :: visited
        for d in depsList do
          if !nextFrontier.contains d && !visited.any (fun (n, _) => n == d) then
            nextFrontier := d :: nextFrontier
    frontier := nextFrontier
  return visited

/-- Serialize to JSON object -/
def serializeNode (pair : Name × List Name) : TermElabM Json := do
  let nameStr := pair.fst.toString
  let category ← try getConstCategory pair.fst catch | _ => pure "unknown"
  let refs := pair.snd.map (fun n => Json.str n.toString)
  return Json.mkObj [
    ("id", Json.str nameStr),
    ("name", Json.str nameStr),
    ("decl_type", Json.str category),
    ("dependencies", Json.arr refs.toArray)
  ]

def dumpSubgraphToJson (roots : List Name) (depth : Nat) (outFile : String) : TermElabM Unit := do
  let subg ← extractBFSSubgraph roots depth
  let jsonNodes ← subg.mapM serializeNode
  let fullJson := Json.mkObj [
    ("generator", Json.str "LeanGraph.Native"),
    ("roots", Json.arr (roots.map (fun r => Json.str r.toString)).toArray),
    ("depth", Json.num depth),
    ("nodes", Json.arr jsonNodes.toArray)
  ]
  IO.FS.writeFile outFile (toString fullJson)

end LeanGraph.Native
