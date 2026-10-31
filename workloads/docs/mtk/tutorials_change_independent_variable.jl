# env: sciml
# kind: overcompile
# source: tutorials/change_independent_variable.md

# %% 1
using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as D
@variables x(t) y(t)
@parameters g=9.81 v # gravitational acceleration and horizontal velocity
eqs = [D(D(y)) ~ -g, D(x) ~ v]
initialization_eqs = [D(x) ~ D(y)] # 45° initial angle
M1 = System(eqs, t; initialization_eqs, name = :M)
M1s = mtkcompile(M1)
@assert length(equations(M1s)) == 3 # hide
M1s # hide

# %% 2
M2 = change_independent_variable(M1, x)
M2s = mtkcompile(M2; allow_symbolic = true)
# a sanity test on the 10 x/y variables that are accessible to the user # hide
@assert allequal([x, M1s.x]) # hide
@assert allequal([M2.x, M2s.x]) # hide
@assert allequal([y, M1s.y]) # hide
@assert allunique([M1.x, M1.y, M2.y, M2s.y]) # hide
@assert length(equations(M2s)) == 2 # hide
M2s # display this # hide

# %% 3
using OrdinaryDiffEq, Plots
prob = ODEProblem(M2s, [M2s.y => 0.0, v => 8.0], [0.0, 10.0]) # throw 10 meters
sol = solve(prob, Tsit5())
plot(sol; idxs = M2.y) # must index by M2.y = y(x); not M1.y = y(t)!

# %% 4
@variables a(t) Ω(t)
a = GlobalScope(a) # global var needed by all species
function species(w; kw...)
    eqs = [D(Ω) ~ -3(1 + w) * D(a) / a * Ω]
    return System(eqs, t, [Ω], []; kw...)
end
@named r = species(1 // 3) # radiation
@named m = species(0) # matter
@named Λ = species(-1) # dark energy / cosmological constant
eqs = [Ω ~ r.Ω + m.Ω + Λ.Ω, D(a) ~ √(Ω) * a^2]
initialization_eqs = [Λ.Ω + r.Ω + m.Ω ~ 1]
M1 = System(eqs, t, [Ω, a], []; initialization_eqs, name = :M)
M1 = compose(M1, r, m, Λ)
M1s = mtkcompile(M1)

# %% 5
prob = ODEProblem(M1s, [M1s.a => 1.0, M1s.r.Ω => 5e-5, M1s.m.Ω => 0.3], (0.0, -3.3))
sol = solve(prob, Tsit5(); reltol = 1e-5)
@assert Symbol(sol.retcode) == :Unstable # surrounding text assumes this was unstable # hide
plot(sol, idxs = [M1s.a, M1s.r.Ω / M1s.Ω, M1s.m.Ω / M1s.Ω, M1s.Λ.Ω / M1s.Ω])

# %% 6
M2 = change_independent_variable(M1, M1.a)
@assert !ModelingToolkit.isautonomous(M2) # hide
M2 # hide

# %% 7
a = M2.a # get independent variable of M2
Da = Differential(a)
@variables b(a)
M3 = change_independent_variable(M2, b, [Da(b) ~ exp(-b), a ~ exp(b)])

# %% 8
M3s = mtkcompile(M3; allow_symbolic = true)
prob = ODEProblem(M3s, [M3s.r.Ω => 5e-5, M3s.m.Ω => 0.3], (0, -15))
sol = solve(prob, Tsit5())
@assert Symbol(sol.retcode) == :Success # surrounding text assumes the solution was successful # hide
plot(sol, idxs = [M3s.r.Ω / M3s.Ω, M3s.m.Ω / M3s.Ω, M3s.Λ.Ω / M3s.Ω])
