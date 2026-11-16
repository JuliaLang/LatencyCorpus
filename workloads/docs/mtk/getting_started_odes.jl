# env: sciml
# kind: overcompile
# source: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/docs/src/getting_started/odes.md
# license: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/LICENSE.md

# %% 1
using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as D

# %% 2
@variables x(t)
@parameters τ

# %% 3
eqs = [D(x) ~ (1 - x) / τ]

# %% 4
sys = System(eqs, t, [x], [τ]; name = :sys)

# %% 5
@named sys = System(eqs, t, [x], [τ])

# %% 6
@named sys = System(eqs, t)

# %% 7
simp_sys = mtkcompile(sys)

# %% 8
@mtkcompile sys = System(eqs, t)

# %% 9
prob = ODEProblem(sys, [x => 0.0, τ => 3.0], (0.0, 10.0))

# %% 10
using OrdinaryDiffEq

sol = solve(prob)

# %% 11
sol[x]

# %% 12
sol[(1 - x) / τ]

# %% 13
using Plots

plot(sol)

# %% 14
plot(sol; idxs = (1 - x) / τ)
