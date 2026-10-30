# env: sciml
# kind: unknown
# source: features/ensemble.md

# %% 1
import DifferentialEquations as DE
prob = DE.ODEProblem((u, p, t) -> 1.01u, 0.5, (0.0, 1.0))
prob_func(prob, ctx) = DE.remake(prob, u0 = rand() * prob.u0)
ensemble_prob = DE.EnsembleProblem(prob; prob_func)
sim = DE.solve(ensemble_prob, DE.Tsit5(), DE.EnsembleThreads(), trajectories = 10)
import Plots: plot
plot(sim)

# %% 2
initial_conditions = range(0, stop = 1, length = 100)
prob_func(prob, ctx) = DE.remake(prob, u0 = initial_conditions[ctx.sim_id])

# %% 3
function f(du, u, p, t)
    du[1] = p[1] * u[1] - p[2] * u[1] * u[2]
    du[2] = -3 * u[2] + u[1] * u[2]
    return
end

# %% 4
function g(du, u, p, t)
    du[1] = p[3] * u[1]
    du[2] = p[4] * u[2]
    return
end

# %% 5
import DifferentialEquations as DE
import StochasticDiffEq: EnsembleProblem, SDEProblem, SRIW1, solve
p = [1.5, 1.0, 0.1, 0.1]
prob = SDEProblem(f, g, [1.0, 1.0], (0.0, 10.0), p)

# %% 6
# pruned: failed without tiering
# %% 7
# pruned: failed without tiering
# %% 8
# pruned: failed without tiering
# %% 9
summ = DE.EnsembleSummary(sim, 0:0.1:10)
plot(summ, fillalpha = 0.5)

# %% 10
output_func(sol, ctx) = (sol.u[end], false)

# %% 11
import DifferentialEquations as DE
# Linear ODE which starts at 0.5 and solves from t=0.0 to t=1.0
prob = DE.ODEProblem((u, p, t) -> 1.01u, 0.5, (0.0, 1.0))

prob_func(prob, ctx) = DE.remake(prob, u0 = rand() * prob.u0)

# %% 12
import Statistics: mean, var
function reduction(u, batch, I)
    u = append!(u, batch)
    finished = (var(u) / sqrt(last(I))) / mean(u) < 0.5
    return u, finished
end

# %% 13
prob2 = DE.EnsembleProblem(
    prob; prob_func, output_func, reduction, u_init = Vector{Float64}()
)
sim = DE.solve(prob2, DE.Tsit5(), trajectories = 10000, batch_size = 20)

# %% 14
reduction(u, batch, I) = (u + sum(batch), false)
prob2 = DE.EnsembleProblem(prob; prob_func, output_func, reduction, u_init = 0.0)
sim2 = DE.solve(prob2, DE.Tsit5(), trajectories = 100, batch_size = 20)

# %% 15
function f(du, u, p, t)
    for i in 1:length(u)
        du[i] = 1.01 * u[i]
    end
    return
end
function σ(du, u, p, t)
    for i in 1:length(u)
        du[i] = 0.87 * u[i]
    end
    return
end
import DifferentialEquations as DE
prob = DE.SDEProblem(f, σ, ones(4, 2) / 2, (0.0, 1.0)) #prob_sde_2Dlinear

# %% 16
import StochasticDiffEq: SRIW1
prob2 = DE.EnsembleProblem(prob)
sim = DE.solve(prob2, SRIW1(), dt = 1 // 2^3, trajectories = 10, adaptive = false);
@info "Ensemble solution computed with $(length(sim)) trajectories" # hide
nothing # hide

# %% 17
import DifferentialEquations as DE
m, v = DE.EnsembleAnalysis.timestep_meanvar(sim, 3)

# %% 18
m, v = DE.EnsembleAnalysis.timepoint_meanvar(sim, 0.5)

# %% 19
m_series, v_series = DE.EnsembleAnalysis.timeseries_steps_meanvar(sim)

# %% 20
ts = 0:0.1:1
m_series = DE.EnsembleAnalysis.timeseries_point_mean(sim, ts)

# %% 21
DE.EnsembleAnalysis.timeseries_steps_meancov(sim) # Use the time steps, assume fixed dt
dt = 1 // 2^3
DE.EnsembleAnalysis.timeseries_point_meancov(sim, 0:dt:1, 0:dt:1) # Use time points, interpolate

# %% 22
summ = DE.EnsembleSummary(sim)

# %% 23
summ = DE.EnsembleSummary(sim, 0.0:0.1:1.0)

# %% 24
import Plots: plot
plot(summ; idxs = 3);

# %% 25
plot(summ; idxs = (3, 5), error_style = :bars)

# %% 26
plot(summ; error_style = :none)
