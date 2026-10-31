# env: sciml
# kind: overcompile
# source: tutorials/programmatically_generating.md

# %% 1
using ModelingToolkit # reexports Symbolics
@independent_variables t
@variables x(t) y(t) # Define variables
D = Differential(t)
eqs = [D(x) ~ y
       D(y) ~ x] # Define an array of equations

# %% 2
using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as D
@variables x(t) = 0.0  # independent and dependent variables
@parameters τ = 3.0       # parameters
@constants h = 1    # constants
eqs = [D(x) ~ (h - x) / τ] # create an array of equations

# your first ODE, consisting of a single equation, indicated by ~
@named model = System(eqs, t)

# Perform the standard transformations and mark the model complete
# Note: Complete models cannot be subsystems of other models!
fol = mtkcompile(model)
prob = ODEProblem(fol, [], (0.0, 10.0))
using OrdinaryDiffEq
sol = solve(prob)

using Plots
plot(sol)

# %% 3
fol_model = System(eqs, t; name = :fol_model) # @named fol_model = System(eqs, t)

# %% 4
namesym = :name_from_file
fol_model = System(eqs, t; name = namesym)
