# env: sciml
# kind: overcompile
# source: examples/higher_order.md

# %% 1
using ModelingToolkit, OrdinaryDiffEq
using ModelingToolkit: t_nounits as t, D_nounits as D

@parameters σ = 28.0 ρ = 10.0 β = 8 / 3
@variables x(t) = 1.0 y(t) = 0.0 z(t) = 0.0
eqs = [
    D(D(x)) ~ σ * (y - x)
    D(y) ~ x * (ρ - z) - y
    D(z) ~ x * y - β * z
]

@named sys_model = System(eqs, t)
sys = mtkcompile(sys_model)

# %% 2
u0 = [D(sys.x) => 2.0]
tspan = (0.0, 100.0)
prob = ODEProblem(sys, u0, tspan, jac = true)
sol = solve(prob, Tsit5())
using Plots
plot(sol, idxs = (sys.x, sys.y))
