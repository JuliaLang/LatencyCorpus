# env: sciml
# kind: interactive
# about: A short ModelingToolkit model: build it, simplify, solve and plot, then change a parameter and solve again.

# %% load
using ModelingToolkit, OrdinaryDiffEq, Plots
using ModelingToolkit: t_nounits as t, D_nounits as D

# %% model
@parameters k = 2.0 c = 0.3
@variables x(t) = 1.0 v(t) = 0.0
@named osc = System([D(x) ~ v, D(v) ~ -k * x - c * v], t)
sys = mtkcompile(osc)

# %% solve
prob = ODEProblem(sys, [], (0.0, 20.0))
sol = solve(prob, Tsit5())

# %% plot
plot(sol; idxs = [x, v])

# %% another parameter
sol2 = solve(remake(prob; p = [k => 5.0]), Tsit5())
sol2[x][end]
