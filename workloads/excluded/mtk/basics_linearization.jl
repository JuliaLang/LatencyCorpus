# env: sciml
# kind: unknown
# source: basics/Linearization.md

# %% 1
using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as D
@variables x(t)=0 y(t) u(t) r(t)=0
@parameters kp = 1

eqs = [u ~ kp * (r - y) # P controller
       D(x) ~ -x + u    # First-order plant
       y ~ x]           # Output equation

@named sys = System(eqs, t) # Do not call @mtkcompile when linearizing
matrices, simplified_sys = linearize(sys, [r], [y]) # Linearize from r to y
matrices

# %% 2
using ModelingToolkit: inputs, outputs
[unknowns(simplified_sys); inputs(simplified_sys); outputs(simplified_sys)]

# %% 3
using ModelingToolkitStandardLibrary
using ModelingToolkitStandardLibrary.Blocks

@parameters k=10 k3=2 c=1
@variables x(t)=0 [bounds = (-0.5, 1.5)]
@variables v(t) = 0

@named y = Blocks.RealOutput()
@named u = Blocks.RealInput()

eqs = [D(x) ~ v
       D(v) ~ -k * x - k3 * x^3 - c * v + 10u.u
       y.u ~ x]

@named duffing = System(eqs, t, systems = [y, u], initial_conditions = [u.u => 0])

# pass a constant value for `x`, since it is the variable we will change in operating points
linfun, simplified_sys = linearization_function(duffing, [u.u], [y.u]; op = Dict(x => NaN));

println(linearize(simplified_sys, linfun; op = Dict(x => 1.0)))
println(linearize(simplified_sys, linfun; op = Dict(x => 0.0)))

@time linearize(simplified_sys, linfun; op = Dict(x => 0.0))

nothing # hide

# %% 4
using SymbolicIndexingInterface

# The second argument is the value of the independent variable `t`.
linprob = LinearizationProblem(linfun, 1.0)
# It can be mutated
linprob.t = 0.0
# create a setter function to update `x` efficiently
setter! = setu(linprob, x)

function fast_linearize!(problem, setter!, value)
    setter!(problem, value)
    solve(problem)
end

println(fast_linearize!(linprob, setter!, 1.0))
println(fast_linearize!(linprob, setter!, 0.0))

@time fast_linearize!(linprob, setter!, 1.0)

nothing # hide

# %% 5
# pruned: failed without tiering
# %% 6
# pruned: failed without tiering
# %% 7
# pruned: failed without tiering
