# env: sciml
# kind: overcompile
# source: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/docs/src/examples/modelingtoolkitize_index_reduction.md
# license: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/LICENSE.md

# %% 1
using ModelingToolkit
using LinearAlgebra
using OrdinaryDiffEq
using Plots

function pendulum!(du, u, p, t)
    x, dx, y, dy, T = u
    g, L = p
    du[1] = dx
    du[2] = T * x
    du[3] = dy
    du[4] = T * y - g
    du[5] = x^2 + y^2 - L^2
    return nothing
end
pendulum_fun! = ODEFunction(pendulum!, mass_matrix = Diagonal([1, 1, 1, 1, 0]))
u0 = [1.0, 0, 0, 0, 0]
p = [9.8, 1]
tspan = (0, 10.0)
pendulum_prob = ODEProblem(pendulum_fun!, u0, tspan, p)
traced_sys = modelingtoolkitize(pendulum_prob)
pendulum_sys = mtkcompile(dae_index_lowering(traced_sys))
prob = ODEProblem(pendulum_sys, [], tspan)
sol = solve(prob, Rodas5P(), abstol = 1e-8, reltol = 1e-8)
plot(sol, idxs = unknowns(traced_sys))

# %% 2
using OrdinaryDiffEq, LinearAlgebra
function pendulum!(du, u, p, t)
    x, dx, y, dy, T = u
    g, L = p
    du[1] = dx
    du[2] = T * x
    du[3] = dy
    du[4] = T * y - g
    du[5] = x^2 + y^2 - L^2
end
pendulum_fun! = ODEFunction(pendulum!, mass_matrix = Diagonal([1, 1, 1, 1, 0]))
u0 = [1.0, 0, 0, 0, 0];
p = [9.8, 1];
tspan = (0, 10.0);
pendulum_prob = ODEProblem(pendulum_fun!, u0, tspan, p)
solve(pendulum_prob, Rodas5P())

# %% 3
traced_sys = modelingtoolkitize(pendulum_prob)
pendulum_sys = mtkcompile(dae_index_lowering(traced_sys))
prob = ODEProblem(pendulum_sys, Pair[], tspan)
sol = solve(prob, Rodas5P())

using Plots
plot(sol, idxs = unknowns(traced_sys))
