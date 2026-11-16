# env: sciml
# kind: overcompile
# source: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/docs/src/tutorials/initialization.md
# license: https://github.com/SciML/ModelingToolkit.jl/blob/v11.46.1/LICENSE.md

# %% 1
using ModelingToolkit, Test
using ModelingToolkit: t_nounits as t, D_nounits as D

@variables x(t) y(t)
@parameters p q
@mtkcompile sys = System([D(x) ~ p * x + y, y ~ q * x], t; bindings = [y => x, q => 2p],
                         initial_conditions = [x => 1, p => 1])

# %% 2
bindings(sys)

# %% 3
@test_throws Exception bindings(sys)[y] = 2x # throws

# %% 4
initial_conditions(sys)

# %% 5
initial_conditions(sys)[x] = 2

# %% 6
initial_conditions(sys)

# %% 7
tspan = (0.0, 1.0)

# %% 8
ODEProblem(sys, [], tspan) # fine

# %% 9
ODEProblem(sys, [x => 2, p => 2.5], tspan) # fine

# %% 10
@test_throws Exception ODEProblem(sys, [y => 1], tspan) # errors

# %% 11
@test_throws Exception ODEProblem(sys, [q => 2], tspan) # errors

# %% 12
using OrdinaryDiffEq, Plots

@parameters g
@variables x(t) y(t) [state_priority = 10] λ(t)
eqs = [D(D(x)) ~ λ * x
       D(D(y)) ~ λ * y - g
       x^2 + y^2 ~ 1]
@mtkcompile pend = System(eqs, t)

# %% 13
prob = ODEProblem(pend, [x => 1, y => 0, g => 1], (0.0, 1.5), guesses = [λ => 1])

# %% 14
sol = solve(prob, Rodas5P())
plot(sol, idxs = (x, y))

# %% 15
conditions = getfield.(equations(pend)[3:end], :rhs)

# %% 16
[sol[conditions][1]; sol[x][1] - 1; sol[y][1]]

# %% 17
sol[λ][1]

# %% 18
prob = ODEProblem(pend, [x => 1, λ => 0, g => 1], (0.0, 1.5); guesses = [y => 1])
sol = solve(prob, Rodas5P())
plot(sol, idxs = (x, y))

# %% 19
prob = ODEProblem(
    pend, [x => 1, D(y) => 0, g => 1], (0.0, 1.5); guesses = [λ => 0, y => 1])
sol = solve(prob, Rodas5P())
plot(sol, idxs = (x, y))

# %% 20
prob = ODEProblem(pend, [x => 1, g => 1], (0.0, 1.5); guesses = [λ => 0, y => 1],
    initialization_eqs = [y ~ 0])
sol = solve(prob, Rodas5P())
plot(sol, idxs = (x, y))

# %% 21
prob = ODEProblem(
    pend, [x => 1, D(y) => g, g => 1], (0.0, 3.0); guesses = [λ => 0, y => 1])
sol = solve(prob, Rodas5P())
plot(sol, idxs = (x, y))

# %% 22
conditions = getfield.(equations(pend)[3:end], :rhs)

# %% 23
prob = ODEProblem(pend, [x => 1, y => 0, g => 1], (0.0, 1.5); guesses = [y => 0, λ => 1])

# %% 24
prob = ODEProblem(pend, [x => 1, D(y) => 0, g => 1], (0.0, 1.5); guesses = [y => 0, λ => 1])

# %% 25
prob = ODEProblem(pend, [x => 1, g => 1], (0.0, 1.5); guesses = [y => 0, λ => 1])

# %% 26
sol = solve(prob, Rodas5P())
plot(sol, idxs = (x, y))

# %% 27
prob = ODEProblem(
    pend, [x => 1, y => 0.0, D(y) => 0, g => 1], (0.0, 1.5); guesses = [λ => 1])

# %% 28
sol = solve(prob, Rodas5P())
plot(sol, idxs = (x, y))

# %% 29
prob = ODEProblem(
    pend, [x => 1, y => 0.0, D(y) => 2.0, λ => 1, g => 1], (0.0, 1.5); guesses = [λ => 1])
sol = solve(prob, Rodas5P())

# %% 30
equations(pend)

# %% 31
observed(pend)

# %% 32
prob = ODEProblem(
    pend, [x => 1, D(y) => 0, g => 1], (0.0, 1.5); guesses = [λ => 0, y => 1, x => 1])
sol1 = solve(prob, Rodas5P())

# %% 33
sol1[D(y), 1]

# %% 34
prob.ps[[Initial(x), Initial(D(y))]]

# %% 35
prob.ps[Initial(D(y))] = -0.1
sol2 = solve(prob, Rodas5P())

# %% 36
sol2[D(y), 1]

# %% 37
sol2[D(x), 1]

# %% 38
prob.ps[Initial(D(x))] = 1.0

# %% 39
sol3 = solve(prob, Rodas5P())

# %% 40
sol3[D(x), 1]

# %% 41
prob2 = remake(prob; u0 = [y => 0.0, D(x) => 0.0, x => nothing, D(y) => nothing]);

# %% 42
sol4 = solve(prob2, Rodas5P())

# %% 43
sol4[D(x), 1]

# %% 44
using ModelingToolkit, OrdinaryDiffEq # hidden
using ModelingToolkit: t_nounits as t, D_nounits as D # hidden

@variables x(t) y(t)
@parameters total
@mtkcompile sys = System([D(x) ~ -x, total ~ x + y], t; bindings = [total => missing])

# %% 45
prob = ODEProblem(sys, [x => 1.0, y => 2.0], (0.0, 1.0))
integ = init(prob, Tsit5())
@assert integ.ps[total] ≈ 3.0 # hide
integ.ps[total]

# %% 46
prob2 = remake(prob; u0 = [y => 1.0], p = [total => 4.0])
initsys = prob2.f.initializeprob.f.sys

# %% 47
[equations(initsys); observed(initsys)]

# %% 48
prob2 = remake(prob; u0 = [y => 1.0, x => nothing], p = [total => 4.0])
initsys = prob2.f.initializeprob.f.sys

# %% 49
[equations(initsys); observed(initsys)]

# %% 50
isys = generate_initializesystem(pend; op = [x => 1.0, y => 0.0], guesses = [λ => 1])

# %% 51
equations(isys)

# %% 52
unknowns(isys)

# %% 53
isys = mtkcompile(isys; fully_determined = false)

# %% 54
isys = ModelingToolkit.generate_initializesystem(
    pend; op = [x => 1, y => 0.0, D(y) => 2.0, λ => 1], guesses = [λ => 1])

# %% 55
isys = mtkcompile(isys; fully_determined = false)

# %% 56
equations(isys)

# %% 57
unknowns(isys)

# %% 58
observed(isys)

# %% 59
iprob = ModelingToolkit.InitializationProblem(pend, 0.0,
    [x => 1, y => 0.0, D(y) => 2.0, λ => 1, g => 1], guesses = [λ => 1])

# %% 60
using NonlinearSolve
sol = solve(iprob)

# %% 61
sol.stats

# %% 62
sol = solve(iprob, GaussNewton())

# %% 63
sol.resid

# %% 64
iprob = ModelingToolkit.InitializationProblem(pend, 0.0,
    [x => 1, y => 0.0, D(y) => 0.0, λ => 0, g => 1], guesses = [λ => 1])

# %% 65
sol = solve(iprob)

# %% 66
sol.resid

# %% 67
iprob = ModelingToolkit.InitializationProblem(pend, 0.0,
    [x => 1, D(x) => 0.0, g => 1], guesses = [λ => 1, y => 0])

# %% 68
sol = solve(iprob)

# %% 69
sol = solve(iprob, TrustRegion())
