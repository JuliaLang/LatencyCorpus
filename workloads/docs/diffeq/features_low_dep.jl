# env: sciml
# kind: interactive
# source: features/low_dep.md

# %% 1
import OrdinaryDiffEq as ODE
import OrdinaryDiffEqLowOrderRK: Euler
import DiffEqCallbacks: ProbIntsUncertainty
import SciMLBase: EnsembleProblem
function fitz(du, u, p, t)
    V, R = u
    a, b, c = p
    du[1] = c * (V - V^3 / 3 + R)
    du[2] = -(1 / c) * (V - a - b * R)
    return
end
u0 = [-1.0; 1.0]
tspan = (0.0, 20.0)
p = (0.2, 0.2, 3.0)
prob = ODE.ODEProblem(fitz, u0, tspan, p)
cb = ProbIntsUncertainty(0.2, 1)
ensemble_prob = EnsembleProblem(prob)
sim = ODE.solve(ensemble_prob, Euler(), trajectories = 100, callback = cb, dt = 1 / 10)

# %% 2
import InteractiveUtils: @which # hide
@which ProbIntsUncertainty(0.2, 1)
