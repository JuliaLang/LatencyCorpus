# env: sciml
# kind: overcompile
# about: Build a sizeable acausal model with ModelingToolkit, then sweep its parameters.
# throughput: sweep

# %% load
using ModelingToolkit, OrdinaryDiffEq
using ModelingToolkit: t_nounits as t, D_nounits as D

# %% chain
function mass_spring_chain(n)
    @variables x(t)[1:n] v(t)[1:n]
    @parameters k c m
    eqs = Equation[]
    for i in 1:n
        left = i == 1 ? 0 : x[i-1]
        right = i == n ? x[i] : x[i+1]
        push!(eqs, D(x[i]) ~ v[i])
        push!(eqs, m * D(v[i]) ~ -k * (x[i] - left) + k * (right - x[i]) - c * v[i] - 0.1 * x[i]^3)
    end
    return System(eqs, t; name=:chain)
end
chain = mass_spring_chain(40)
sys = mtkcompile(chain)
length(unknowns(sys))

# %% problem
u0 = [unknowns(sys) .=> [i == 1 ? 1.0 : 0.0 for i in eachindex(unknowns(sys))];
      parameters(sys) .=> [1.0 for _ in parameters(sys)]]
prob = ODEProblem(sys, u0, (0.0, 5000.0))
sol = solve(prob, Tsit5(); reltol=1e-8)
sol.retcode

# %% sweep
ks = range(0.5, 2.0; length=400)
energies = map(ks) do k
    p = remake(prob; p=[sys.k => k])
    s = solve(p, Tsit5(); reltol=1e-8, save_everystep=false)
    sum(abs2, s.u[end])
end
extrema(energies)
