# env: sciml
# kind: overcompile
# source: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/docs/src/basics/Debugging.md
# license: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/LICENSE.md

# %% 1
using ModelingToolkit, OrdinaryDiffEq
using ModelingToolkit: t_nounits as t, D_nounits as D

@variables u1(t) u2(t) u3(t)
eqs = [D(u1) ~ -√(u1), D(u2) ~ -√(u2), D(u3) ~ -√(u3)]
initial_conditions = [u1 => 1.0, u2 => 2.0, u3 => 3.0]
@named sys = System(eqs, t; initial_conditions)
sys = mtkcompile(sys)

# %% 2
prob = ODEProblem(sys, [], (0.0, 10.0));

# %% 3
sol = solve(prob, Tsit5());

# %% 4
dsys = debug_system(sys; functions = [sqrt]);

# %% 5
dprob = ODEProblem(dsys, [], (0.0, 10.0));

# %% 6
# pruned: failed without tiering
# %% 7
@mtkcompile sys = System(eqs, t; initial_conditions, assertions = [(u1 + u2 >= 2.0) => "Oh no!"])

# %% 8
prob = ODEProblem(sys, [], (0.0, 10.0))
sol = solve(prob, Tsit5())

# %% 9
dsys = debug_system(sys; functions = []);

# %% 10
dprob = ODEProblem(dsys, [], (0.0, 10.0));

# %% 11
dsol = solve(dprob, Tsit5(); dtmin = 0.1); # high dtmin only to show less clutter on this page

# %% 12
# pruned: failed without tiering
# %% 13
solve(dprob, Tsit5());
