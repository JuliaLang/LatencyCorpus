# env: sciml
# kind: interactive
# source: https://github.com/SciML/DiffEqDocs.jl/blob/2be200d2e925d9ddaa99cc9f38de808704d5c4b5/docs/src/basics/problem.md
# license: https://github.com/SciML/DiffEqDocs.jl/blob/2be200d2e925d9ddaa99cc9f38de808704d5c4b5/LICENSE.md

# %% 1
import DifferentialEquations as DE
prob = DE.ODEProblem((u, p, t) -> u, (p, t0) -> p[1], (p) -> (0.0, p[2]), (2.0, 1.0))

# %% 2
import Distributions
prob = DE.ODEProblem((u, p, t) -> u, (p, t) -> Distributions.Normal(p, 1), (0.0, 1.0), 1.0)

# %% 3
prob1 = DE.ODEProblem((u, p, t) -> u / 2, 1.0, (0.0, 1.0))
prob2 = DE.remake(prob1; tspan = (0.0, 2.0))
