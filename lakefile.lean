import Lake
open Lake DSL

package «SocrateAI-Scientific-Agora-LeanMaster» where
  srcDir := "."

@[default_target]
lean_lib «StringTheoryFoundation» where
  roots := #[`StringTheoryFoundation]

@[default_target]
lean_lib «DualScaleM24Formalization» where
  roots := #[`DualScaleM24Formalization]

@[default_target]
lean_lib «DoubleFieldTheory» where
  roots := #[`DoubleFieldTheory]

@[default_target]
lean_lib «DualScaleValidation» where
  roots := #[`DualScaleValidation]
