# env: sciml
# kind: overcompile
# source: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/docs/src/examples/remake.md
# license: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/LICENSE.md

# %% 1
using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as D

@parameters α β γ δ
@variables x(t) y(t)
eqs = [D(x) ~ (α - β * y) * x
       D(y) ~ (δ * x - γ) * y]
@mtkcompile odesys = System(eqs, t)

# %% 2
using OrdinaryDiffEq

odeprob = ODEProblem(
    odesys, [x => 1.0, y => 1.0, α => 1.5, β => 1.0, γ => 3.0, δ => 1.0], (0.0, 10.0))
timesteps = 0.0:0.1:10.0
sol = solve(odeprob, Tsit5(); saveat = timesteps)
data = Array(sol)
# add some random noise
data = data + 0.01 * randn(size(data))

# %% 3
using SymbolicIndexingInterface: parameter_values, state_values
using SciMLStructures: Tunable, canonicalize, replace, replace!
using PreallocationTools

function loss(x, p)
    odeprob = p[1] # ODEProblem stored as parameters to avoid using global variables
    ps = parameter_values(odeprob) # obtain the parameter object from the problem
    diffcache = p[5]
    # get an appropriately typed preallocated buffer to store the `x` values in
    buffer = get_tmp(diffcache, x)
    # copy the current values to this buffer
    copyto!(buffer, canonicalize(Tunable(), ps)[1])
    # create a copy of the parameter object with the buffer
    ps = replace(Tunable(), ps, buffer)
    # set the updated values in the parameter object
    setter = p[4]
    setter(ps, x)
    # remake the problem, passing in our new parameter object
    newprob = remake(odeprob; p = ps)
    timesteps = p[2]
    sol = solve(newprob, AutoTsit5(Rosenbrock23()); saveat = timesteps)
    truth = p[3]
    data = Array(sol)
    return sum((truth .- data) .^ 2) / length(truth)
end

# %% 4
using Optimization
using OptimizationOptimJL: Optim
using SymbolicIndexingInterface

# manually create an OptimizationFunction to ensure usage of `ForwardDiff`, which will
# require changing the types of parameters from `Float64` to `ForwardDiff.Dual`
optfn = OptimizationFunction(loss, Optimization.AutoForwardDiff())
# function to set the parameters we are optimizing
setter = setp(odeprob, [α, β, γ, δ])
# `DiffCache` to avoid allocations.
# `copy` prevents the buffer stored by `DiffCache` from aliasing the one in
# `parameter_values(odeprob)`.
diffcache = DiffCache(copy(canonicalize(Tunable(), parameter_values(odeprob))[1]))
# parameter object is a tuple, to store differently typed objects together
optprob = OptimizationProblem(
    optfn, rand(4), (odeprob, timesteps, data, setter, diffcache),
    lb = 0.1zeros(4), ub = 3ones(4))
sol = solve(optprob, Optim.BFGS())
