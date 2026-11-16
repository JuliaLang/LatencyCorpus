# env: sciml
# kind: overcompile
# source: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/docs/src/tutorials/ode_modeling.md
# license: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/LICENSE.md
# throughput: 17
# throughput: 18
# throughput: 19

# %% 1
using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as D

@parameters τ = 3.0 # parameters
@variables x(t) = 0.0 # dependent variables
eqs = [D(x) ~ (1 - x) / τ]

@named fol_model = System(eqs, t)

using OrdinaryDiffEq
fol = mtkcompile(fol_model)
prob = ODEProblem(fol, [], (0.0, 10.0))
sol = solve(prob)

using Plots
plot(sol)

# %% 2
using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as D

@parameters τ = 3.0 # parameters and their values
@variables x(t) = 0.0 # dependent variables and their initial conditions
eqs = [D(x) ~ (1 - x) / τ]

@named fol_model = System(eqs, t)
fol = mtkcompile(fol_model)

# %% 3
using OrdinaryDiffEq
using Plots

prob = ODEProblem(fol, [], (0.0, 10.0))
plot(solve(prob))

# %% 4
prob = ODEProblem(fol, [fol.x => 0.5, fol.τ => 1 / 3], (0.0, 10.0))
plot(solve(prob))

# %% 5
using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as D

@parameters τ = 3.0 # parameters and their values
@variables x(t) = 0.0 RHS(t) # dependent variables and their initial conditions
eqs = [
    RHS ~ (1 - x) / τ
    D(x) ~ RHS
]

@named fol_model = System(eqs, t)
fol = mtkcompile(fol_model)

# %% 6
equations(fol)

# %% 7
observed(fol)

# %% 8
prob = ODEProblem(fol, [], (0.0, 10.0))
sol = solve(prob)
plot(sol, idxs = [fol.x, fol.RHS])

# %% 9
sol[fol.x]

# %% 10
sol[fol.x, 2]

# %% 11
sol[fol.RHS]

# %% 12
@parameters τ = 3.0 # parameters and their values
@variables x(t) = 0.0 f(t) # dependent variables and their initial conditions
eqs = [
    f ~ sin(t)
    D(x) ~ (f - x) / τ
]

@named fol_model = System(eqs, t)
fol_variable_f = mtkcompile(fol_model)

# %% 13
value_vector = randn(10)
f_fun(t) = t >= 10 ? value_vector[end] : value_vector[Int(floor(t)) + 1]
@register_symbolic f_fun(t)

@parameters τ = 0.75 # parameters and their values
@variables x(t) = 0.0 f(t) # dependent variables and their initial conditions
eqs = [
    f ~ f_fun(t)
    D(x) ~ (f - x) / τ
]

@named fol_model = System(eqs, t)
fol_external_f = mtkcompile(fol_model)

# %% 14
prob = ODEProblem(fol_external_f, [], (0.0, 10.0))
sol = solve(prob)
plot(sol, idxs = [fol_external_f.x, fol_external_f.f])

# %% 15
# Define a reusable component function that creates a first-order lag system
function FOLComponent(; name, τ = 1.0, x0 = 0.0)
    @parameters τ = τ
    @variables x(t) = x0 f(t) RHS(t)
    eqs = [
        RHS ~ f
        D(x) ~ (RHS - x) / τ
    ]
    return System(eqs, t, [x, f, RHS], [τ]; name)
end

# Create two instances of the component with different parameters
@named fol_1 = FOLComponent(τ = 2.0, x0 = -0.5)
@named fol_2 = FOLComponent(τ = 4.0, x0 = 1.0)

# Connect them: fol_1 has constant input, fol_2 uses fol_1's output
connection_eqs = [
    fol_1.f ~ 1.5
    fol_2.f ~ fol_1.x
]

@named connected_model = System(connection_eqs, t, [], []; systems = [fol_1, fol_2])
connected = mtkcompile(connected_model)

# %% 16
prob = ODEProblem(connected, [], (0.0, 10.0))
plot(solve(prob))

# %% 17
using BenchmarkTools
using OrdinaryDiffEqRosenbrock: Rodas4
@btime solve(prob, Rodas4());
nothing # hide

# %% 18
prob_an = ODEProblem(connected, [], (0.0, 10.0); jac = true)
@btime solve(prob_an, Rodas4());
nothing # hide

# %% 19
prob_sparse = ODEProblem(connected, [], (0.0, 10.0); jac = true, sparse = true)
@btime solve(prob_sparse, Rodas4());
nothing # hide
