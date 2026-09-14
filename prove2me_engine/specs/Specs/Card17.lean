namespace Prove2Me.Specs

def Card17Statement : Prop :=
  ∀ (trace_H_initial : Int) (delta_trace : Int),
    delta_trace = 0 → trace_H_initial + delta_trace = trace_H_initial

end Prove2Me.Specs
