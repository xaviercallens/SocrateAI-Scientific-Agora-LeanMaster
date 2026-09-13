import Lake
open Lake DSL

package «DualScaleM24Formalization» where
  srcDir := ".."

@[default_target]
lean_lib «DualScaleM24Formalization» where
  roots := #[`DualScaleM24Formalization]
