# env: sciml
# kind: interactive
# source: tutorials/rode_example.md

# %% 1
import StochasticDiffEq as SDE
import Plots: plot
f3(u, p, t, W) = 2u * sin(W)
u0 = 1.0
tspan = (0.0, 5.0)
prob = SDE.RODEProblem(f3, u0, tspan)
sol = SDE.solve(prob, SDE.RandomEM(); dt = 1 / 100)
plot(sol)

# %% 2
import StochasticDiffEq as SDE
import Plots: plot
function f(du, u, p, t, W)
    du[1] = 2u[1] * sin(W[1] - W[2])
    du[2] = -2u[2] * cos(W[1] + W[2])
    return
end
u0 = [1.0; 1.0]
tspan = (0.0, 5.0)
prob = SDE.RODEProblem(f, u0, tspan)
sol = SDE.solve(prob, SDE.RandomEM(); dt = 1 / 100)
plot(sol)

# %% 3
import StochasticDiffEq as SDE
import Plots: plot
function f(du, u, p, t, W)
    du[1] = -2W[3] * u[1] * sin(W[1] - W[2])
    du[2] = -2u[2] * cos(W[1] + W[2])
    return
end
u0 = [1.0; 1.0]
tspan = (0.0, 5.0)
prob = SDE.RODEProblem(f, u0, tspan; rand_prototype = zeros(3))
sol = SDE.solve(prob, SDE.RandomEM(); dt = 1 / 100)
plot(sol)
