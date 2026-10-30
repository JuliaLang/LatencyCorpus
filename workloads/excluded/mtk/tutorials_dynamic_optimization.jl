# env: sciml
# kind: unknown
# source: tutorials/dynamic_optimization.md

# %% 1
using ModelingToolkit, OrdinaryDiffEq
t = ModelingToolkit.t_nounits
D = ModelingToolkit.D_nounits

@parameters h_c m₀ h₀ g₀ D_c c Tₘ m_c
@variables begin
    h(..)
    v(..)
    m(..), [bounds = (m_c, 1)]
    T(..), [input = true, bounds = (0, Tₘ)]
end

drag(h, v) = D_c * v^2 * exp(-h_c * (h - h₀) / h₀)
gravity(h) = g₀ * (h₀ / h)

eqs = [D(h(t)) ~ v(t),
    D(v(t)) ~ (T(t) - drag(h(t), v(t))) / m(t) - gravity(h(t)),
    D(m(t)) ~ -T(t) / c]

(ts, te) = (0.0, 0.2)
costs = [-h(te)]
cons = [T(te) ~ 0, m(te) ~ m_c]

@named rocket = System(eqs, t; costs, constraints = cons)
rocket = mtkcompile(rocket, inputs = [T(t)])

u0map = [h(t) => h₀, m(t) => m₀, v(t) => 0]
pmap = [
    g₀ => 1, m₀ => 1.0, h_c => 500, c => 0.5 * √(g₀ * h₀), D_c => 0.5 * 620 * m₀ / g₀,
    Tₘ => 3.5 * g₀ * m₀, T(t) => 0.0, h₀ => 1, m_c => 0.6]

# %% 2
# pruned: failed without tiering
# %% 3
# pruned: failed without tiering
# %% 4
# pruned: failed without tiering
# %% 5
# pruned: failed without tiering
# %% 6
# pruned: failed without tiering
# %% 7
# pruned: failed without tiering
# %% 8
@variables begin
    x(..)
    v(..)
    u(..), [bounds = (-1.0, 1.0), input = true]
end

@parameters tf

constr = [v(tf) ~ 0, x(tf) ~ 0]
cost = [tf] # Minimize time

@named block = System(
    [D(x(t)) ~ v(t), D(v(t)) ~ u(t)], t; costs = cost, constraints = constr)

block = mtkcompile(block; inputs = [u(t)])

u0map = [x(t) => 1.0, v(t) => 0.0]
tspan = (0.0, tf)
parammap = [u(t) => 0.0, tf => 1.0]

# %% 9
# pruned: failed without tiering
# %% 10
# pruned: failed without tiering
# %% 11
@parameters α = 1.5 β = 1.0 [tunable=false] γ = 3.0 δ = 1.0
@variables x_pe(t) y_pe(t)

eqs_pe = [D(x_pe) ~ α * x_pe - β * x_pe * y_pe,
    D(y_pe) ~ -γ * y_pe + δ * x_pe * y_pe]

@mtkcompile sys0_pe = System(eqs_pe, t)
tspan_pe = (0.0, 1.0)
u0map_pe = [x_pe => 4.0, y_pe => 2.0]

# True parameter values (these are what we'll try to recover)
parammap_pe = [α => 2.5, δ => 1.8]

oprob_pe = ODEProblem(sys0_pe, [u0map_pe; parammap_pe], tspan_pe)
osol_pe = solve(oprob_pe, Tsit5())

# Generate synthetic data at 51 time points
ts_pe = range(tspan_pe..., length=51)
data_pe = osol_pe(ts_pe, idxs=x_pe).u

# %% 12
costs_pe = [abs2(EvalAt(ti)(x_pe) - data_pe[i]) for (i, ti) in enumerate(ts_pe)]

@mtkcompile sys_pe = System(eqs_pe, t; costs = costs_pe)

# %% 13
sys_pe′ = subset_tunables(sys_pe, [α, δ])

# %% 14
# pruned: failed without tiering
# %% 15
# pruned: failed without tiering
# %% 16
# pruned: failed without tiering
