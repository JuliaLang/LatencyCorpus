# env: sciml
# kind: unknown
# source: tutorials/nonlinear.md

# %% 1
using ModelingToolkit, NonlinearSolve

# Define a nonlinear system
@variables x y z
@parameters σ ρ β
eqs = [0 ~ σ * (y - x)
       0 ~ x * (ρ - z) - y
       0 ~ x * y - β * z]
@mtkcompile ns = System(eqs)

guesses = [x => 1.0, y => 0.0, z => 0.0]
ps = [σ => 10.0, ρ => 26.0, β => 8 / 3]

prob = NonlinearProblem(ns, vcat(guesses, ps))
sol = solve(prob, NewtonRaphson())

# %% 2
prob = NonlinearProblem(ns, vcat(guesses, ps), jac = true)
sol = solve(prob, NewtonRaphson())
