# env: sciml
# kind: throughput
# about: Long-running ODE work: a long chaotic integration, a stiff system, a method-of-lines
#   PDE and an ensemble, as in a research script.

# %% load
using DifferentialEquations, OrdinaryDiffEqSDIRK, LinearAlgebra, Statistics

# %% lorenz
function lorenz!(du, u, p, t)
    σ, ρ, β = p
    du[1] = σ * (u[2] - u[1])
    du[2] = u[1] * (ρ - u[3]) - u[2]
    du[3] = u[1] * u[2] - β * u[3]
end
prob = ODEProblem(lorenz!, [1.0, 0.0, 0.0], (0.0, 3.0e6), (10.0, 28.0, 8 / 3))
sol = solve(prob, Tsit5(); reltol=1e-10, abstol=1e-10, save_everystep=false)
sol.u[end]

# %% stiff
function rober!(du, u, p, t)
    k1, k2, k3 = p
    du[1] = -k1 * u[1] + k3 * u[2] * u[3]
    du[2] = k1 * u[1] - k2 * u[2]^2 - k3 * u[2] * u[3]
    du[3] = k2 * u[2]^2
end
stiff = ODEProblem(rober!, [1.0, 0.0, 0.0], (0.0, 1e11), (0.04, 3e7, 1e4))
[solve(stiff, alg; reltol=1e-8, abstol=1e-10).retcode for alg in (Rodas5P(), FBDF(), KenCarp4())]

# %% heat equation
function heat!(du, u, p, t)
    n, dx2 = p
    du[1] = (u[2] - 2u[1]) / dx2
    for i in 2:n-1
        du[i] = (u[i-1] - 2u[i] + u[i+1]) / dx2
    end
    du[n] = (u[n-1] - 2u[n]) / dx2
end
n = 500
x = range(0, 1; length=n)
heat = ODEProblem(heat!, exp.(-100 .* (x .- 0.5) .^ 2), (0.0, 0.1), (n, step(x)^2))
hsol = solve(heat, FBDF(); reltol=1e-8)
maximum(hsol.u[end])

# %% ensemble
pendulum(u, p, t) = [u[2], -p * sin(u[1])]
base = ODEProblem(pendulum, [0.0, 1.0], (0.0, 200.0), 9.81)
ens = EnsembleProblem(base; prob_func=(prob, ctx) -> remake(prob; u0=[0.0, 0.5 + ctx.sim_id / 4000]))
esol = solve(ens, Vern9(), EnsembleSerial(); trajectories=10_000, reltol=1e-10, save_everystep=false)
mean(s.u[end][1] for s in esol.u)
