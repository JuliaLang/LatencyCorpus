# env: sciml
# kind: unknown
# source: tutorials/sde_example.md

# %% 1
import StochasticDiffEq as SDE
α = 1
β = 1
u₀ = 1 / 2
f(u, p, t) = α * u
g(u, p, t) = β * u
dt = 1 // 2^4
tspan = (0.0, 1.0)
prob = SDE.SDEProblem(f, g, u₀, tspan)

# %% 2
sol = SDE.solve(prob, SDE.EM(); dt);
nothing # hide

# %% 3
import Plots: plot, plot!
plot(sol)

# %% 4
u_analytic(u₀, p, t, W) = u₀ * exp((α - β^2 / 2) * t + β * W)
ff = SDE.SDEFunction(f, g, analytic = u_analytic)
prob = SDE.SDEProblem(ff, u₀, (0.0, 1.0))

# %% 5
sol = SDE.solve(prob, SDE.EM(); dt);
nothing # hide

# %% 6
plot(sol, plot_analytic = true)

# %% 7
sol = SDE.solve(prob, SDE.SRIW1(); dt, adaptive = false);
nothing # hide

# %% 8
plot(sol, plot_analytic = true)

# %% 9
sol = SDE.solve(prob, SDE.SRIW1());
nothing # hide

# %% 10
plot(sol, plot_analytic = true)

# %% 11
sol = SDE.solve(prob, SDE.SRIW1(); dt);
nothing # hide

# %% 12
plot(sol, plot_analytic = true)

# %% 13
ensembleprob = SDE.EnsembleProblem(prob)

# %% 14
sol = SDE.solve(ensembleprob, SDE.EnsembleThreads(), trajectories = 1000);
@info "Ensemble solution computed with $(length(sol.u)) trajectories" # hide
nothing # hide

# %% 15
import StochasticDiffEq as SDE
summ = SDE.EnsembleSummary(sol, 0:0.01:1)
plot(summ, labels = "Middle 95%")
summ = SDE.EnsembleSummary(sol, 0:0.01:1; quantiles = [0.25, 0.75])
plot!(summ, labels = "Middle 50%", legend = true)

# %% 16
SDE.EnsembleAnalysis.timepoint_meancor(sol, 0.2, 0.7) # Gives both means and then the correlation coefficient

# %% 17
import StochasticDiffEq as SDE
import Plots: plot

function f!(du, u, p, t)
    du[1] = 10.0 * (u[2] - u[1])
    du[2] = u[1] * (28.0 - u[3]) - u[2]
    du[3] = u[1] * u[2] - (8 / 3) * u[3]
    return
end

function g!(du, u, p, t)  # It actually represents a diagonal matrix [3.0 0 0; 0 3.0 0; 0 0 3.0]
    du[1] = 3.0
    du[2] = 3.0
    du[3] = 3.0
    return
end

prob_sde_lorenz = SDE.SDEProblem(f!, g!, [1.0, 0.0, 0.0], (0.0, 10.0))
sol = SDE.solve(prob_sde_lorenz);
nothing # hide

# %% 18
plot(sol, idxs = (1, 2, 3))

# %% 19
function g!(du, u, p, t)
    du[1] = sin(u[3]) * 3.0
    du[2] = u[2] * u[1] * 3.0
    du[3] = 3.0
    return
end

# %% 20
import StochasticDiffEq as SDE
import Plots: plot
f!(du, u, p, t) = (du .= u)
g!(du, u, p, t) = (du .= u)
u0 = rand(4, 2)

W = SDE.WienerProcess(0.0, 0.0, 0.0)
prob = SDE.SDEProblem(f!, g!, u0, (0.0, 1.0), noise = W)
sol = SDE.solve(prob, SDE.SRIW1());
nothing # hide

# %% 21
plot(sol)

# %% 22
import StochasticDiffEq as SDE
f!(du, u, p, t) = du .= 1.01u
function g!(du, u, p, t)
    du[1, 1] = 0.3u[1]
    du[1, 2] = 0.6u[1]
    du[1, 3] = 0.9u[1]
    du[1, 4] = 0.12u[1]
    du[2, 1] = 1.2u[2]
    du[2, 2] = 0.2u[2]
    du[2, 3] = 0.3u[2]
    du[2, 4] = 1.8u[2]
    return
end
prob = SDE.SDEProblem(f!, g!, ones(2), (0.0, 1.0), noise_rate_prototype = zeros(2, 4))

# %% 23
# Define a sparse matrix by making a dense matrix and setting some values as not zero
import SparseArrays: sparse
A = zeros(2, 4)
A[1, 1] = 1
A[1, 4] = 1
A[2, 4] = 1
A = sparse(A)

# Make `g!` write the sparse matrix values
function g!(du, u, p, t)
    du[1, 1] = 0.3u[1]
    du[1, 4] = 0.12u[2]
    du[2, 4] = 1.8u[2]
    return
end

# Make `g!` use the sparse matrix
prob = SDE.SDEProblem(f!, g!, ones(2), (0.0, 1.0), noise_rate_prototype = A)

# %% 24
function f!(du, u, p, t)
    du[1] = μ * u[1]
    du[2] = κ * (Θ - u[2])
    return
end
function g!(du, u, p, t)
    du[1] = √u[2] * u[1]
    du[2] = σ * √u[2]
    return
end

# %% 25
ρ = 0.2
Γ = [1 ρ; ρ 1]

# %% 26
tspan = (0.0, 1.0)
heston_noise = SDE.CorrelatedWienerProcess!(Γ, tspan[1], zeros(2), zeros(2))

# %% 27
SDE.SDEProblem(f!, g!, ones(2), tspan, noise = heston_noise)
