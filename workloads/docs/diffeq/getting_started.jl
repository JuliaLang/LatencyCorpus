# env: sciml
# kind: interactive
# source: https://github.com/SciML/DiffEqDocs.jl/blob/2be200d2e925d9ddaa99cc9f38de808704d5c4b5/docs/src/getting_started.md
# license: https://github.com/SciML/DiffEqDocs.jl/blob/2be200d2e925d9ddaa99cc9f38de808704d5c4b5/LICENSE.md

# %% 1
import DifferentialEquations as DE
f(u, p, t) = 1.01 * u
u0 = 1 / 2
tspan = (0.0, 1.0)
prob = DE.ODEProblem(f, u0, tspan)
sol = DE.solve(prob, DE.Tsit5(), reltol = 1.0e-8, abstol = 1.0e-8)

import Plots: plot, plot!
plot(
    sol, linewidth = 5, title = "Solution to the linear ODE with a thick line",
    xaxis = "Time (t)", yaxis = "u(t) (in μm)", label = "My Thick Line!", # legend=false
)
plot!(sol.t, t -> 0.5 * exp(1.01t), lw = 3, ls = :dash, label = "True Solution!")

# %% 2
import DifferentialEquations as DE
f(u, p, t) = 1.01 * u
u0 = 1 / 2
tspan = (0.0, 1.0)
prob = DE.ODEProblem(f, u0, tspan)

# %% 3
sol = DE.solve(prob)

# %% 4
typeof(sol)

# %% 5
@info "Solution contains $(length(sol.t)) time points from t=$(sol.t[1]) to t=$(sol.t[end])"

# %% 6
sol = DE.solve(prob, reltol = 1.0e-6);
nothing # hide

# %% 7
sol = DE.solve(prob, reltol = 1e-6, saveat = 0.1);
nothing # hide

# %% 8
sol = DE.solve(prob, reltol = 1.0e-6, save_everystep = false);
nothing # hide

# %% 9
sol = DE.solve(prob, alg_hints = [:stiff], reltol = 1.0e-8, abstol = 1.0e-8);
nothing # hide

# %% 10
sol = DE.solve(prob, DE.Tsit5());
nothing # hide

# %% 11
sol = DE.solve(prob, DE.Tsit5(), reltol = 1.0e-8, abstol = 1.0e-8);
nothing # hide

# %% 12
sol.u[5]

# %% 13
sol.t[8]

# %% 14
[t + u for (u, t) in zip(sol.u, sol.t)]

# %% 15
[t + 2u for (u, t) in zip(sol.u, sol.t)]

# %% 16
sol(0.45) # The value of the solution at t=0.45

# %% 17
#]add Plots # You need to install Plots.jl before your first time using it!
import Plots: plot, plot!
#plotly() # You can optionally choose a plotting backend
plot(sol)

# %% 18
plot(
    sol, linewidth = 5, title = "Solution to the linear ODE with a thick line",
    xaxis = "Time (t)", yaxis = "u(t) (in μm)", label = "My Thick Line!", # legend=false
)

# %% 19
plot!(sol.t, t -> 0.5 * exp(1.01t), lw = 3, ls = :dash, label = "True Solution!")

# %% 20
function lorenz!(du, u, p, t)
    du[1] = 10.0 * (u[2] - u[1])
    du[2] = u[1] * (28.0 - u[3]) - u[2]
    du[3] = u[1] * u[2] - (8 / 3) * u[3]
    return
end

# %% 21
import DifferentialEquations as DE
u0 = [1.0; 0.0; 0.0]
tspan = (0.0, 100.0)
prob = DE.ODEProblem(lorenz!, u0, tspan)
sol = DE.solve(prob)
@info "Solution has $(length(sol.t)) timesteps" # hide
nothing # hide

# %% 22
import Plots: plot
plot(sol, idxs = (1, 2, 3))

# %% 23
plot(sol, idxs = (0, 2))

# %% 24
function parameterized_lorenz!(du, u, p, t)
    du[1] = p[1] * (u[2] - u[1])
    du[2] = u[1] * (p[2] - u[3]) - u[2]
    du[3] = u[1] * u[2] - p[3] * u[3]
    return
end

# %% 25
u0 = [1.0, 0.0, 0.0]
tspan = (0.0, 1.0)
p = [10.0, 28.0, 8 / 3]
prob = DE.ODEProblem(parameterized_lorenz!, u0, tspan, p)

# %% 26
function parameterized_lorenz!(du, u, p, t)
    x, y, z = u
    σ, ρ, β = p
    du[1] = dx = σ * (y - x)
    du[2] = dy = x * (ρ - z) - y
    du[3] = dz = x * y - β * z
    return
end

# %% 27
import DifferentialEquations as DE
import Plots: plot

l = 1.0                             # length [m]
m = 1.0                             # mass [kg]
g = 9.81                            # gravitational acceleration [m/s²]

function pendulum!(du, u, p, t)
    du[1] = u[2]                    # θ'(t) = ω(t)
    du[2] = -3g / (2l) * sin(u[1]) + 3 / (m * l^2) * p(t) # ω'(t) = -3g/(2l) sin θ(t) + 3/(ml^2)M(t)
    return
end

θ₀ = 0.01                           # initial angular deflection [rad]
ω₀ = 0.0                            # initial angular velocity [rad/s]
u₀ = [θ₀, ω₀]                       # initial state vector
tspan = (0.0, 10.0)                 # time interval

M = t -> 0.1sin(t)                  # external torque [Nm]

prob = DE.ODEProblem(pendulum!, u₀, tspan, M)
sol = DE.solve(prob)

plot(
    sol, linewidth = 2, xaxis = "t", label = ["θ [rad]" "ω [rad/s]"], layout = (2, 1)
)

# %% 28
import DifferentialEquations as DE
import Plots: plot
A = [
    1.0 0 0 -5
    4 -2 4 -3
    -4 0 0 1
    5 -2 2 3
]
u0 = rand(4, 2)
tspan = (0.0, 1.0)
f(u, p, t) = A * u
prob = DE.ODEProblem(f, u0, tspan)

# %% 29
sol = DE.solve(prob)
plot(sol)

# %% 30
import LinearAlgebra
f(du, u, p, t) = LinearAlgebra.mul!(du, A, u)

# %% 31
import StaticArrays: @SMatrix
A = @SMatrix [
    1.0 0.0 0.0 -5.0
    4.0 -2.0 4.0 -3.0
    -4.0 0.0 0.0 1.0
    5.0 -2.0 2.0 3.0
]
u0 = @SMatrix rand(4, 2)
tspan = (0.0, 1.0)
f2(u, p, t) = A * u
prob = DE.ODEProblem(f2, u0, tspan)
sol = DE.solve(prob)
plot(sol)

# %% 32
sol.u[4]

# %% 33
sol[5, 3]

# %% 34
sol[2, 1, :]
