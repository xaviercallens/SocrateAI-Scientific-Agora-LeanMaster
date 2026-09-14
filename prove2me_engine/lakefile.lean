import Lake
open Lake DSL

package «prove2me_engine» where

@[default_target]
lean_lib «Specs» where
  srcDir := "specs"

@[default_target]
lean_lib «Proofs» where
  srcDir := "proofs"
