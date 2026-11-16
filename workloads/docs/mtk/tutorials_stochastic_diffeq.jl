# env: sciml
# kind: overcompile
# source: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/docs/src/tutorials/stochastic_diffeq.md
# license: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/LICENSE.md

# %% 1
using ModelingToolkit, StochasticDiffEq
using ModelingToolkit: t_nounits as t, D_nounits as D
using Plots

@parameters σ=10.0 ρ=2.33 β=26.0
@variables x(t)=5.0 y(t)=5.0 z(t)=1.0
@brownians B
eqs = [D(x) ~ σ * (y - x) + 0.3x * B,
    D(y) ~ x * (ρ - z) - y + 0.3y * B,
    D(z) ~ x * y - β * z + 0.3z * B]

@mtkcompile de = System(eqs, t)

# %% 2
typeof(de)

# %% 3
prob = SDEProblem(de, [], (0.0, 100.0))
sol = solve(prob, SRIW1())
plot(sol, idxs = [(1, 2, 3)])

# %% 4
plot(sol)

# %% 5
@brownians Bx By Bz
eqs = [D(x) ~ σ * (y - x) + 0.3x * Bx,
    D(y) ~ x * (ρ - z) - y + 0.3y * By,
    D(z) ~ x * y - β * z + 0.3z * Bz]
@mtkcompile de = System(eqs, t)
prob = SDEProblem(de, [], (0.0, 100.0))
sol = solve(prob, SRIW1())
plot(sol)
